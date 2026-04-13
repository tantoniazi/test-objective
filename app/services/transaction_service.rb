# frozen_string_literal: true

class TransactionService
  TAXAS = { "D" => 0.03, "C" => 0.05, "P" => 0.0 }.freeze

  def initialize(account, forma_pagamento, valor)
    @account = account
    @forma_pagamento = forma_pagamento.to_s.upcase
    @valor = BigDecimal(valor.to_s)
  end

  def call
    return erro("Forma de pagamento inválida") unless TAXAS.key?(@forma_pagamento)

    case @forma_pagamento
    when "C"
      creditar!
    else
      debitar!
    end
  end

  private

  def debitar!
    @account.with_lock do
      @account.reload
      taxa = TAXAS[@forma_pagamento]
      valor_total = @valor + (@valor * taxa)

      return erro("Saldo insuficiente") if @account.saldo < valor_total

      @account.saldo -= valor_total
      @account.save!
      @account.transactions.create!(
        forma_pagamento: @forma_pagamento,
        valor: @valor,
        valor_liquido: -valor_total
      )
      { sucesso: true, saldo: @account.saldo }
    end
  rescue ActiveRecord::RecordInvalid => e
    erro(e.record.errors.full_messages.join(", "))
  end

  def creditar!
    @account.with_lock do
      @account.reload
      taxa = TAXAS["C"]
      valor_liquido = @valor - (@valor * taxa)

      @account.saldo += valor_liquido
      @account.save!
      @account.transactions.create!(
        forma_pagamento: "C",
        valor: @valor,
        valor_liquido: valor_liquido
      )
      { sucesso: true, saldo: @account.saldo }
    end
  rescue ActiveRecord::RecordInvalid => e
    erro(e.record.errors.full_messages.join(", "))
  end

  def erro(mensagem)
    { sucesso: false, erro: mensagem }
  end
end

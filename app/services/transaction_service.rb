class TransactionService
  TAXAS = { 'D' => 0.03, 'C' => 0.05, 'P' => 0.0 }.freeze

  def initialize(account, forma_pagamento, valor)
    @account         = account
    @forma_pagamento = forma_pagamento
    @valor           = valor.to_f
  end

  def call
    taxa          = TAXAS[@forma_pagamento] || 0
    valor_total   = @valor + (@valor * taxa)

    if @account.saldo < valor_total
      return { sucesso: false, erro: 'Saldo insuficiente' }
    end

    @account.saldo -= valor_total

    if @account.save
      { sucesso: true, saldo: @account.saldo }
    else
      { sucesso: false, erro: 'Erro ao salvar transação' }
    end
  end
end
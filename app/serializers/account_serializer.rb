# frozen_string_literal: true

class AccountSerializer < ActiveModel::Serializer
  attributes :numero_conta, :saldo, :transacoes

  def saldo
    object.saldo.to_f
  end

  def transacoes
    object.transactions.sort_by(&:created_at).reverse.first(20).map do |t|
      TransactionSerializer.new(t).as_json
    end
  end
end

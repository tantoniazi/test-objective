# frozen_string_literal: true

class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :forma_pagamento, :valor, :valor_liquido, :created_at

  def valor
    object.valor.to_f
  end

  def valor_liquido
    object.valor_liquido.to_f
  end
end

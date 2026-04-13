# frozen_string_literal: true

class TransactionsController < ApplicationController
  include ApiErrorReporting

  def create
    account = current_user.accounts.find_by!(numero_conta: transaction_params[:numero_conta])

    resultado = TransactionService.new(
      account,
      transaction_params[:forma_pagamento],
      transaction_params[:valor]
    ).call

    if resultado[:sucesso]
      render json: {
        numero_conta: account.reload.numero_conta,
        saldo: account.saldo.to_f
      }, status: :created
    else
      render json: { erro: resultado[:erro] }, status: :unprocessable_entity
    end
  end

  private

  def transaction_params
    params.permit(:forma_pagamento, :numero_conta, :valor)
  end
end

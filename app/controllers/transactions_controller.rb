class TransactionsController < ApplicationController
  def create
    account = Account.find_by(numero_conta: params[:numero_conta])

    unless account
      render json: { erro: 'Conta não encontrada' }, status: :not_found
      return
    end

    resultado = TransactionService.new(account, params[:forma_pagamento], params[:valor]).call

    if resultado[:sucesso]
      render json: { numero_conta: account.numero_conta, saldo: resultado[:saldo] }, status: :created
    else
      render json: { erro: resultado[:erro] }, status: :not_found
    end
  end
end
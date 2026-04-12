class AccountsController < ApplicationController
  def create
    if Account.exists?(numero_conta: params[:numero_conta])
      render json: { erro: 'Conta já existente' }, status: :unprocessable_entity
      return
    end

    account = Account.new(numero_conta: params[:numero_conta], saldo: params[:saldo])

    if account.save
      render json: { numero_conta: account.numero_conta, saldo: account.saldo }, status: :created
    else
      render json: { erros: account.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    account = Account.find_by(numero_conta: params[:numero_conta])

    if account
      render json: { numero_conta: account.numero_conta, saldo: account.saldo }
    else
      render json: { erro: 'Conta não encontrada' }, status: :not_found
    end
  end
end´
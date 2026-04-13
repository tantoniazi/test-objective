# frozen_string_literal: true

class AccountsController < ApplicationController
  include ApiErrorReporting

  def create
    if Account.exists?(numero_conta: account_params[:numero_conta])
      render json: { erro: "Conta já existente" }, status: :unprocessable_entity
      return
    end

    account = current_user.accounts.build(account_params)

    if account.save
      render json: AccountSerializer.new(account).as_json, status: :created
    else
      render json: { erros: account.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    account = current_user.accounts.includes(:transactions).find_by!(numero_conta: params.require(:numero_conta))

    render json: AccountSerializer.new(account).as_json
  end

  private

  def account_params
    params.permit(:numero_conta, :saldo)
  end
end

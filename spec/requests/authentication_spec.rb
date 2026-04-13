# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Autenticação", type: :request do
  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user) }

  it "retorna 401 ao acessar GET /conta sem sessão" do
    get "/conta", params: { numero_conta: account.numero_conta }
    expect(response).to have_http_status(:unauthorized)
    expect(response.body).to be_present
  end

  it "retorna 401 ao criar conta sem sessão" do
    post "/conta", params: { numero_conta: 1, saldo: 0 }, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "retorna 401 ao criar transação sem sessão" do
    post "/transacao",
      params: { numero_conta: account.numero_conta, forma_pagamento: "P", valor: 1 },
      as: :json
    expect(response).to have_http_status(:unauthorized)
  end
end

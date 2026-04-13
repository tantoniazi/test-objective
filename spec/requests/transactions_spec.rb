# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Transações", type: :request do
  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user, numero_conta: 99_001, saldo: 1000) }

  before { sign_in user, scope: :user }

  it "processa Pix" do
    post "/transacao",
      params: { numero_conta: 99_001, forma_pagamento: "P", valor: 50 },
      as: :json
    expect(response).to have_http_status(:created)
    expect(response.parsed_body["saldo"]).to eq(950.0)
  end

  it "processa Débito com taxa" do
    post "/transacao",
      params: { numero_conta: 99_001, forma_pagamento: "D", valor: 100 },
      as: :json
    expect(response).to have_http_status(:created)
    expect(response.parsed_body["saldo"]).to eq(897.0)
  end

  it "processa Crédito com taxa" do
    post "/transacao",
      params: { numero_conta: 99_001, forma_pagamento: "C", valor: 200 },
      as: :json
    expect(response).to have_http_status(:created)
    expect(response.parsed_body["saldo"]).to eq(1190.0)
  end

  it "retorna 422 quando saldo insuficiente" do
    post "/transacao",
      params: { numero_conta: 99_001, forma_pagamento: "D", valor: 999_999 },
      as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body["erro"]).to eq("Saldo insuficiente")
  end

  it "retorna 404 quando numero_conta não existe para o usuário" do
    other = create(:account, numero_conta: 12_345)
    post "/transacao",
      params: { numero_conta: other.numero_conta, forma_pagamento: "P", valor: 1 },
      as: :json
    expect(response).to have_http_status(:not_found)
  end
end

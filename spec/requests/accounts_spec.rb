# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contas", type: :request do
  let(:user) { create(:user) }
  let!(:owned) { create(:account, user: user, numero_conta: 77_001, saldo: 250.5) }

  before { sign_in user, scope: :user }

  describe "POST /conta" do
    it "cria conta para o usuário autenticado" do
      expect do
        post "/conta", params: { numero_conta: 77_002, saldo: 10.25 }, as: :json
      end.to change(Account, :count).by(1)

      expect(response).to have_http_status(:created)
      json = response.parsed_body
      expect(json["numero_conta"]).to eq(77_002)
      expect(json["saldo"]).to eq(10.25)
      expect(json["transacoes"]).to eq([])
    end

    it "rejeita numero_conta duplicado" do
      post "/conta", params: { numero_conta: 77_001, saldo: 0 }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["erro"]).to eq("Conta já existente")
    end
  end

  describe "GET /conta" do
    it "retorna a conta do usuário com transações" do
      TransactionService.new(owned, "P", 10).call

      get "/conta", params: { numero_conta: 77_001 }
      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["numero_conta"]).to eq(77_001)
      expect(json["saldo"]).to eq(240.5)
      expect(json["transacoes"].size).to eq(1)
    end

    it "retorna 404 quando a conta não pertence ao usuário" do
      other = create(:account, numero_conta: 88_001)
      get "/conta", params: { numero_conta: other.numero_conta }
      expect(response).to have_http_status(:not_found)
    end
  end
end

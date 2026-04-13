# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /conta (N+1)", type: :request do
  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user, numero_conta: 66_001, saldo: 500) }

  before do
    5.times do |i|
      account.transactions.create!(
        forma_pagamento: "P",
        valor: i + 1,
        valor_liquido: -(i + 1)
      )
    end
    sign_in user, scope: :user
  end

  it "não dispara consultas N+1 ao serializar transações (Bullet)" do
    expect do
      get "/conta", params: { numero_conta: account.numero_conta }
    end.not_to raise_error

    expect(response).to have_http_status(:ok)
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Relatório de erro inesperado", type: :request do
  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user) }

  before { sign_in user, scope: :user }

  it "enfileira email quando ocorre erro não tratado no fluxo da transação" do
    allow(TransactionService).to receive(:new).and_raise(StandardError.new("falha simulada"))

    expect do
      post "/transacao",
        params: { numero_conta: account.numero_conta, forma_pagamento: "P", valor: 1 },
        as: :json
    end.to have_enqueued_mail(SystemErrorMailer, :notify)

    expect(response).to have_http_status(:internal_server_error)
  end
end

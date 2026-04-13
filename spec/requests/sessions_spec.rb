# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessões Devise", type: :request do
  let!(:user) { create(:user, password: "mypass99", password_confirmation: "mypass99") }

  it "autentica com email e senha corretos" do
    post "/users/sign_in",
      params: { user: { email: user.email, password: "mypass99" } }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["user"]["email"]).to eq(user.email)
  end

  it "rejeita credenciais inválidas" do
    post "/users/sign_in",
      params: { user: { email: user.email, password: "wrong" } }
    expect(response).to have_http_status(:unauthorized)
  end
end

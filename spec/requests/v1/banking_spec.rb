# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API bancária", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user, password: "pass12345", password_confirmation: "pass12345") }
  let!(:account) { create(:account, user: user, numero_conta: 120_001, saldo: 1000) }

  path "/users/sign_in" do
    post "Login (Devise)" do
      tags "Autenticação"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: [:user],
        properties: {
          user: {
            type: :object,
            required: %i[email password],
            properties: {
              email: { type: :string, example: "admin@example.com" },
              password: { type: :string, example: "123456", format: :password }
            }
          }
        }
      }

      response "200", "sessão criada" do
        let(:payload) { { user: { email: user.email, password: "pass12345" } } }

        example "application/json", :login_ok, {
          message: "Login realizado com sucesso",
          user: { id: 1, email: "admin@example.com" }
        }

        run_test!
      end

      response "401", "credenciais inválidas" do
        let(:payload) { { user: { email: user.email, password: "errado" } } }

        example "application/json", :login_fail, {
          erro: "Email ou senha inválidos."
        }

        run_test!
      end
    end
  end

  path "/conta" do
    post "Criar conta" do
      tags "Conta"
      security [{ cookieAuth: [] }]
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %i[numero_conta saldo],
        properties: {
          numero_conta: { type: :integer, example: 10_002 },
          saldo: { type: :number, format: :float, example: 150.75 }
        }
      }

      response "201", "conta criada" do
        let(:payload) { { numero_conta: 130_001, saldo: 200.5 } }

        before do
          post "/users/sign_in", params: { user: { email: user.email, password: "pass12345" } }
        end

        example "application/json", :conta_criada, {
          numero_conta: 130_001,
          saldo: 200.5,
          transacoes: []
        }

        run_test!
      end

      response "401", "não autenticado" do
        let(:payload) { { numero_conta: 1, saldo: 0 } }

        example "application/json", :sem_auth, {
          erro: "Autenticação necessária."
        }

        run_test!
      end
    end

    get "Consultar conta" do
      tags "Conta"
      security [{ cookieAuth: [] }]
      produces "application/json"
      parameter name: :numero_conta, in: :query, type: :integer, required: true,
        example: 120_001

      response "200", "conta encontrada" do
        let(:numero_conta) { account.numero_conta }

        before do
          post "/users/sign_in", params: { user: { email: user.email, password: "pass12345" } }
        end

        example "application/json", :conta_ok, {
          numero_conta: 120_001,
          saldo: 1000.0,
          transacoes: []
        }

        run_test!
      end
    end
  end

  path "/transacao" do
    post "Registrar transação" do
      tags "Transação"
      security [{ cookieAuth: [] }]
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %i[numero_conta forma_pagamento valor],
        properties: {
          numero_conta: { type: :integer, example: 120_001 },
          forma_pagamento: { type: :string, enum: %w[P D C], example: "P" },
          valor: { type: :number, format: :float, example: 50.0 }
        }
      }

      response "201", "transação registrada (Pix)" do
        let(:payload) do
          { numero_conta: account.numero_conta, forma_pagamento: "P", valor: 25 }
        end

        before do
          post "/users/sign_in", params: { user: { email: user.email, password: "pass12345" } }
        end

        example "application/json", :pix_ok, {
          numero_conta: 120_001,
          saldo: 975.0
        }

        run_test!
      end

      response "422", "saldo insuficiente" do
        let(:payload) do
          { numero_conta: account.numero_conta, forma_pagamento: "D", valor: 999_999 }
        end

        before do
          post "/users/sign_in", params: { user: { email: user.email, password: "pass12345" } }
        end

        example "application/json", :saldo_insuficiente, {
          erro: "Saldo insuficiente"
        }

        run_test!
      end
    end
  end
end

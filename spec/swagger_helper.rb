# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("openapi").to_s

  config.openapi_specs = {
    "v1/openapi.yaml" => {
      openapi: "3.0.3",
      info: {
        title: "API bancária",
        description: "Autenticação via JWT Bearer (POST /users/sign_in). Copie o campo `token` da resposta e use como Bearer em rotas privadas.",
        version: "v1"
      },
      paths: {},
      servers: [
        { url: "http://localhost:{port}", variables: { port: { default: "3000" } } }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: "JWT",
            description: "JWT obtido no campo `token` da resposta de POST /users/sign_in"
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end

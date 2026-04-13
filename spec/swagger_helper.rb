# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("openapi").to_s

  config.openapi_specs = {
    "v1/openapi.yaml" => {
      openapi: "3.0.3",
      info: {
        title: "API bancária",
        description: "Autenticação via sessão Devise (POST /users/sign_in). Reutilize o cookie de sessão nas requisições seguintes.",
        version: "v1"
      },
      paths: {},
      servers: [
        { url: "http://localhost:{port}", variables: { port: { default: "3000" } } }
      ],
      components: {
        securitySchemes: {
          cookieAuth: {
            type: :apiKey,
            in: :cookie,
            name: "_test_objective_session",
            description: "Cookie definido após login em POST /users/sign_in"
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end

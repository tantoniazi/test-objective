# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
    controllers: { sessions: "users/sessions" },
    skip: %i[registrations passwords confirmations unlocks]

  mount Rswag::Api::Engine => "/api-docs"
  mount Rswag::Ui::Engine => "/api-docs"

  post "/conta",     to: "accounts#create"
  get  "/conta",     to: "accounts#show"
  post "/transacao", to: "transactions#create"
end

# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    account
    forma_pagamento { "P" }
    valor { 100.00 }
    valor_liquido { -100.00 }
  end
end

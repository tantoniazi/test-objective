# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    user
    sequence(:numero_conta) { |n| n + 50_000 }
    saldo { 10_000.00 }
  end
end

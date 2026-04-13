# frozen_string_literal: true

class Transaction < ApplicationRecord
  FORMAS = %w[P D C].freeze

  belongs_to :account

  validates :forma_pagamento, presence: true, inclusion: { in: FORMAS }
  validates :valor, :valor_liquido, presence: true, numericality: true
end

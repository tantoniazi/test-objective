# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

  validates :numero_conta, presence: true, uniqueness: true
  validates :saldo, numericality: { greater_than_or_equal_to: 0 }
end

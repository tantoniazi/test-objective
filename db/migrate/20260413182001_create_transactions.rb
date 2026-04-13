# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :account, null: false, foreign_key: true
      t.string :forma_pagamento, null: false, limit: 1
      t.decimal :valor, precision: 15, scale: 2, null: false
      t.decimal :valor_liquido, precision: 15, scale: 2, null: false

      t.timestamps
    end
  end
end

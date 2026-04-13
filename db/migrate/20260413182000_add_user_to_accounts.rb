# frozen_string_literal: true

class AddUserToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_reference :accounts, :user, null: false, foreign_key: true
    change_column :accounts, :saldo, :decimal, precision: 15, scale: 2, default: 0, null: false
    add_index :accounts, :numero_conta, unique: true
  end
end

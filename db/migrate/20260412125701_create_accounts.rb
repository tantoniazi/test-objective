class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.integer :numero_conta
      t.decimal :saldo

      t.timestamps
    end
  end
end

class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :crypto, null: false, foreign_key: true
      t.decimal :price
      t.decimal :quantity

      t.timestamps
    end
  end
end

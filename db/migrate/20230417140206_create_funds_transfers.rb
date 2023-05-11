class CreateFundsTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :funds_transfers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :transaction_type
      t.decimal :amount

      t.timestamps
    end
  end
end

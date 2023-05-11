class CreateUserCryptos < ActiveRecord::Migration[7.0]
  def change
    create_table :user_cryptos do |t|
      t.references :user, null: false, foreign_key: true
      t.references :crypto, null: false, foreign_key: true
      t.decimal :quantity, default: 0, null: false

      t.timestamps
    end
  end
end

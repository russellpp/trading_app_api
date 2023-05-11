class AddBalanceToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :balance, :decimal
  end
end

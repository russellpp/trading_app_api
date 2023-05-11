class ChangeAttributeNameInTransactions < ActiveRecord::Migration[7.0]
  def change
    rename_column :transactions, :price, :total_value
  end
end

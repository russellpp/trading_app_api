class AddColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone_number, :string
    add_column :users, :verified, :boolean
  end
end

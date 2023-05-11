class RenameNameToEmailInUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :name, :email
    change_column :users, :email, :string
  end
end

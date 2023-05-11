class AddUserIdToWatchlists < ActiveRecord::Migration[7.0]
  def change
    remove_column :watchlists, :user_id
    add_reference :watchlists, :user, null: false, foreign_key: true
  end
end

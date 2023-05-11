class AddOnWatchlistToUserCrypto < ActiveRecord::Migration[7.0]
  def change
    add_column :user_cryptos, :on_watchlist, :boolean, default: false
  end
end

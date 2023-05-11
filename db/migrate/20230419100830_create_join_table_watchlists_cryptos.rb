class CreateJoinTableWatchlistsCryptos < ActiveRecord::Migration[7.0]
  def change
    create_join_table :watchlists, :cryptos do |t|
      t.index [:watchlist_id, :crypto_id]
      t.index [:crypto_id, :watchlist_id]
    end
  end
end

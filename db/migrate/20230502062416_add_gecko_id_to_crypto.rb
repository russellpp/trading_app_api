class AddGeckoIdToCrypto < ActiveRecord::Migration[7.0]
  def change
    add_column :cryptos, :gecko_id, :string
  end
end

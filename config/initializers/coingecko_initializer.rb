require_relative '../../app/models/application_record'
require 'rest-client'
require 'json'
require_relative '../../app/models/crypto'

class CoingeckoInitializer
  BASE_URL = 'https://api.coingecko.com/api/v3'

  def self.get_coins_list
    url = "#{BASE_URL}/coins/list"
    response = RestClient.get(url)
    JSON.parse(response)
  end

  def self.populate_crypto_from_coingecko
    #Crypto.delete_all # Delete all existing records before creating new ones
    coins = get_coins_list
    coins.each do |coin|
      crypto = Crypto.new
      crypto.ticker = coin['symbol'].upcase
      crypto.name = coin['name']
      crypto.gecko_id = coin['id']
      crypto.save
    end
  end
end

if Crypto.count == 0
  Rails.application.config.after_initialize do
    puts 'populating Cryptos'
    CoingeckoInitializer.populate_crypto_from_coingecko
  end
end



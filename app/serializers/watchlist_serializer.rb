class WatchlistSerializer < ActiveModel::Serializer
	attributes :id, :name
	has_many :cryptos, serializer: CryptoSerializer
end
  
class CryptoSerializer < ActiveModel::Serializer
    attributes :id, :name, :ticker, :gecko_id
  
    attribute :quantity, if: -> { scope.present? && scope[:user_id].present? }
    attribute :on_watchlist, if: -> { scope.present? && scope[:user_id].present? }
  
    delegate :quantity, to: :user_crypto
    delegate :on_watchlist, to: :user_crypto
  
    def user_crypto
      object.user_cryptos.find_by(user_id: scope[:user_id])
    end
end
  
  
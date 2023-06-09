class Watchlist < ApplicationRecord
    belongs_to :user
    has_and_belongs_to_many :cryptos
    
    validates :name, presence: true
end

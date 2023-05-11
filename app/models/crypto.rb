class Crypto < ApplicationRecord
    has_many :user_cryptos
    has_many :users, through: :user_cryptos
    has_many :transactions
    has_and_belongs_to_many :watchlists
end

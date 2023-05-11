class UserCrypto < ApplicationRecord
  belongs_to :user
  belongs_to :crypto

  validates :on_watchlist, inclusion: { in: [true, false] }
  validates :user, presence: true
  validates :crypto, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
end

class FundsTransfer < ApplicationRecord
  belongs_to :user

  validates :transaction_type, presence: true, inclusion: { in: %w[deposit withdraw] }
  validates :amount, presence: true, numericality: { greater_than: 0 }

end

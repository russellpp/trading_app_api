class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :crypto

  validates :transaction_type, presence: true, inclusion: { in: %w[buy sell] }
  validates :total_value, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }

end

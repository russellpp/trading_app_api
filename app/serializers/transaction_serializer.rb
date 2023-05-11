class TransactionSerializer < ActiveModel::Serializer
    attributes :id, :transaction_type, :user_id, :email, :crypto_id, :name, :ticker, :total_value, :quantity, :created_at
  
    delegate :name, to: :crypto
    delegate :ticker, to: :crypto
    delegate :email, to: :user
  
    def crypto
        Crypto.find_by(id: object.crypto_id)
    end

    def user
        User.find_by(id: object.user_id)
    end

end
  
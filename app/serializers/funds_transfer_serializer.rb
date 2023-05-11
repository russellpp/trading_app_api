class FundsTransferSerializer < ActiveModel::Serializer
    attributes :id, :transaction_type, :user_id, :email, :amount
  
    delegate :email, to: :user
 
    def user
        User.find_by(id: object.user_id)
    end

end
  
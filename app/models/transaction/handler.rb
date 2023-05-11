class Transaction
    module Handler

        def self.buy!(user, coin, quantity, total_value)
            error_response = check_quantity_and_total_value(quantity, total_value)
            return error_response if error_response.present?


            cost = total_value
    
            if user&.balance.present? && user.balance >= cost
                transaction = Transaction.create(transaction_type: 'buy', quantity: quantity, total_value: total_value, user: user, crypto: coin)
                user_crypto = UserCrypto.find_or_create_by(user: user, crypto: coin)
        
                if user_crypto.quantity.nil?
                    currently_owned = 0
                else
                    currently_owned = user_crypto.quantity
                end
        
                user_crypto.update(quantity: currently_owned + quantity)
                user.update(balance: user.balance - cost)
                { message: { messages: ["Trade successful. Bought #{quantity} #{coin.ticker} for a total of #{cost} USD."] }, status: :accepted }
            else
                {message: { errors: ['Insufficient balance'] }, status: :unprocessable_entity}
            end
        end
    
        def self.sell!(user, coin, quantity, total_value)
            error_response = check_quantity_and_total_value(quantity, total_value)
            return error_response if error_response.present?


            user_crypto = UserCrypto.find_by(user: user, crypto: coin)
    
            if user_crypto && user_crypto.quantity >= quantity
                sale_value = total_value
                transact= Transaction.create(transaction_type: 'sell', quantity: quantity, total_value: total_value, user: user, crypto: coin)
                user_crypto.update(quantity: user_crypto.quantity - quantity)
                user.update(balance: user.balance + sale_value)
                { message: { messages: ["Trade successful. Sold #{quantity} #{coin.ticker} for a total of #{sale_value} USD. Balance: #{user.balance}"] }, status: :accepted }
            else
                {message: { errors: ['Insufficient coins'] }, status: :unprocessable_entity}
            end
        end

        private
    
        def self.check_quantity_and_total_value(quantity, total_value)
            if quantity.nil? || total_value.nil? || quantity <= 0 || total_value <=0
                {message: { errors: ['Invalid input, cannot be blank or zero.'] }, status: :unprocessable_entity}
            end
        end
    end
end
  
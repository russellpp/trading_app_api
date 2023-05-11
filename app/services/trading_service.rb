class TradingService
    
    #try to refactor these codes under user_crypto & user
    def buy_coin(user, coin, quantity, price)
        cost = quantity * price
    
        if user.balance >= cost
            transaction = Transaction.create(transaction_type: 'buy', quantity: quantity, price: price, user: user, crypto: coin)
            user_crypto = UserCrypto.find_or_create_by(user: user, crypto: coin)

            if user_crypto.quantity.nil?
                currently_owned = 0
            else 
                currently_owned =  user_crypto.quantity
            end

            user_crypto.update(quantity: currently_owned + quantity)
            user.update(balance: user.balance - cost)
            {message: { message: ["Trade successful. Bought #{quantity} coins for #{cost}."] }, status: :accepted}
        else
            {message: { errors: ['Insufficient balance'] }, status: :unprocessable_entity}
        end

    end

    def sell_coin(user, coin, quantity, price)
        user_crypto = UserCrypto.find_by(user: user, crypto: coin)

        if user_crypto && user_crypto.quantity >= quantity
            sale_value = quantity * price
            transaction = Transaction.create(transaction_type: 'sell', quantity: quantity, price: price, user: user, crypto: coin)
            user_crypto.update(quantity: user_crypto.quantity - quantity)
            user.update(balance: user.balance + sale_value)
            {message: { message: ["Trade successful. Sold #{quantity} coins for #{sale_value}. Balance: #{user.balance}"] }, status: :accepted}
        else
            {message: { errors: ['Insufficient coins'] }, status: :unprocessable_entity}
        end

    end

    #refactor these on user
    def deposit(user, amount)
        if user.balance.nil?
            user.update(balance: 0)
        else
            user.update(balance: user.balance + amount)
        end
        transaction = FundsTransfer.create(transaction_type: 'deposit', amount: amount, user: user)
        {message: { messages: ["An amount of #{amount} has been deposited to your account"] }, status: :accepted}
    end
    
    def withdraw(user, amount)
        if user.balance && user.balance >= amount
            user.update(balance: user.balance - amount)
            transaction = FundsTransfer.create(transaction_type: 'withdraw', amount: amount, user: user)
            {message: { messages: ["An amount of #{amount} has been withdrawed to your account. Balance: #{user.balance}"] }, status: :accepted}
        else
            {message: { errors: ['Insufficient balance'] }, status: :unprocessable_entity}
        end
    end

end

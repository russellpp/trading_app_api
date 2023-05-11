require 'faker'

FactoryBot.define do
    factory :transaction do
        total_value { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
        quantity { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    
        user
    
        after(:build) do |transaction|
            transaction.transaction_type = Faker::Boolean.boolean ? 'buy' : 'sell'
            transaction.crypto = Crypto.all.sample 
        end
    end
end
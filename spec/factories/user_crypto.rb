FactoryBot.define do
    factory :user_crypto do
      association :user
      association :crypto
  
      trait :with_quantity do
        quantity { 100 }
      end
    end
  end
  
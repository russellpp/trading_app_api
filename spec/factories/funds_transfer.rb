FactoryBot.define do
    factory :funds_transfer do
      association :user
      transaction_type { 'deposit' }
      amount { 100 }
    end
  end
  
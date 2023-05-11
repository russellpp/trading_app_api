require 'faker'

FactoryBot.define do
    factory :user do
        email { Faker::Internet.email }
        password { "password123" }
        password_confirmation { "password123" }
        phone_number { "+639456#{rand(100000..999999)}" }    
      
      
      trait :admin do
            email { Faker::Internet.email }
            password { "password123" }
            password_confirmation { "password123" }
            phone_number { "+639456#{rand(100000..999999)}" }
            
            after(:create) do |user|
                role = Role.find_or_create_by(name: "admin")
                UserRole.create(user_id: user.id, role_id: role.id)
            end
        end

      trait :trader do
            email { Faker::Internet.email }
            password { "password123" }
            password_confirmation { "password123" }
            phone_number { "+639456#{rand(100000..999999)}" }

            after(:create) do |user|
                role = Role.find_or_create_by(name: "trader")
                UserRole.create(user_id: user.id, role_id: role.id)
            end
        end

      trait :valid_trader do
            email { Faker::Internet.email }
            password { "password123" }
            password_confirmation { "password123" }
            verified { true }
            phone_number { "+639456#{rand(100000..999999)}" }

            after(:create) do |user|
                role = Role.find_or_create_by(name: "trader")
                UserRole.create(user_id: user.id, role_id: role.id)
            end
        end

      trait :trader_with_balance do
            email { Faker::Internet.email }
            password { "password123" }
            password_confirmation { "password123" }
            verified { true }
            balance {5000}
            approved {true}
            phone_number { "+639456#{rand(100000..999999)}" }

            after(:create) do |user|
                role = Role.find_or_create_by(name: "trader")
                UserRole.create(user_id: user.id, role_id: role.id)
            end
        end


    
        
    end
end
  
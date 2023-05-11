require 'faker'

FactoryBot.define do
    factory :role do
       
        trait :admin do
            name {"admin"}
            id {1}
            
        end

        trait :trader do
            name {"trader"}
            id {2}
            
        end

      
    end
end
require 'simplecov'

SimpleCov.start 'rails' do
    add_filter '/app/controllers/api/v1/watchlists_controller.rb'
    add_filter '/app/serializers/watchlist_serializer.rb'
    add_filter '/app/models/watchlist.rb'
    add_filter '/app/controllers/api/v1/sessions_controller.rb'
    add_filter '/app/services/verification.rb'
    add_filter '/app/services/trading_service.rb'
end

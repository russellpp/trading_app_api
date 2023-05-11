require 'rails_helper'
require_relative '../../app/models/user'
require_relative '../../app/models/role'
require_relative '../../app/models/user_role'
require_relative './application_controller_spec'

RSpec.describe Api::V1::CryptosController, type: :controller do
    let(:user) { create(:user, :trader_with_balance) }
    let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'trader') }

    before do
        allow(controller).to receive(:current_user).and_return(user)
        request.headers['Authorization'] = "Bearer #{authorization}"
    end

    describe 'GET #index' do
        it 'returns a list of cryptos' do
          crypto1 = Crypto.find_by(gecko_id: 'bitcoin')
          crypto2 = Crypto.find_by(gecko_id: 'ethereum')
          
          get :index
          
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          cryptos = json_response['cryptos']
          
          
          crypto1_json = cryptos.find { |c| c['id'] == crypto1.id }
          crypto2_json = cryptos.find { |c| c['id'] == crypto2.id }
          
          expect(crypto1_json).not_to be_nil
          expect(crypto1_json['name']).to eq(crypto1.name)
          expect(crypto1_json['ticker']).to eq(crypto1.ticker)
          
          expect(crypto2_json).not_to be_nil
          expect(crypto2_json['name']).to eq(crypto2.name)
          expect(crypto2_json['ticker']).to eq(crypto2.ticker)
        end
      end


end
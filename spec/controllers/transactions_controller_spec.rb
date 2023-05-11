require 'rails_helper'
require_relative '../../app/models/user'
require_relative '../../app/models/role'
require_relative '../../app/models/user_role'
require_relative './application_controller_spec'

RSpec.describe Api::V1::TransactionsController, type: :controller do
    let(:crypto) { Crypto.find_by(id: 500) }
    
  
  
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end
  
    describe 'POST #create' do

      context 'when coin exists for trading and trader buys successfully' do
        let(:user) { create(:user, :trader_with_balance) }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'trader') }
        let(:transaction_params) do
            {
              transaction_type: 'buy',
              quantity: 1,
              total_value: 100,
              user_id: user.id,
              gecko_id: crypto.gecko_id
            }
          end

        before do
          allow(Crypto).to receive(:find_by).and_return(crypto)
          request.headers['Authorization'] = "Bearer #{authorization}"
          post :create, params: {transaction: transaction_params}
        end
  
        it 'creates a new transaction and updates user balance' do
          expect(response).to have_http_status(:accepted) 
          expect(JSON.parse(response.body)['messages']).to include("Trade successful. Bought #{1.0} #{crypto.ticker} for a total of #{100.0} USD.")
          expect(Transaction.count).to eq(1)
          expect(user.balance).to eq(4900)
        end
      end

      context 'when coin exists for trading and trader buys, but insufficient funds' do
        let(:user) { create(:user, :trader_with_balance) }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'trader') }
        let(:transaction_params) do
            {
              transaction_type: 'buy',
              quantity: 1,
              total_value: 5100,
              user_id: user.id,
              gecko_id: crypto.gecko_id
            }
          end

        before do
          allow(Crypto).to receive(:find_by).and_return(crypto)
          request.headers['Authorization'] = "Bearer #{authorization}"
          post :create, params: {transaction: transaction_params}
        end
  
        it 'creates a new transaction and updates user balance' do
          expect(response).to have_http_status(:unprocessable_entity) 
          expect(JSON.parse(response.body)['errors']).to include('Insufficient balance')
        end
      end
      
      context 'when coin exists for trading and trader sells successfully' do
        let(:user) { create(:user, :trader_with_balance) }
        let!(:user_crypto) { create(:user_crypto,:with_quantity, user: user, crypto: crypto) }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'trader') }
        let(:transaction_params) do
            {
              transaction_type: 'sell',
              quantity: 1,
              total_value: 100,
              user_id: user.id,
              gecko_id: crypto.gecko_id
            }
          end

        before do
            allow(Crypto).to receive(:find_by).and_return(crypto)
            request.headers['Authorization'] = "Bearer #{authorization}"
            post :create, params: {transaction: transaction_params}
        end
  
        it 'creates a new transaction and updates user balance' do
            expect(response).to have_http_status(:accepted) 
            expect(JSON.parse(response.body)['messages']).to include("Trade successful. Sold #{1.0} #{crypto.ticker} for a total of #{100.0} USD. Balance: #{5100.0}")
            expect(Transaction.count).to eq(1)
            expect(user.balance).to eq(5100)
        end
      end

      context 'when coin exists for trading and trader sells, but insufficient coins' do
        let(:user) { create(:user, :trader_with_balance) }
        let!(:user_crypto) { create(:user_crypto,:with_quantity, user: user, crypto: crypto) }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'trader') }
        let(:transaction_params) do
            {
              transaction_type: 'sell',
              quantity: 101,
              total_value: 1000,
              user_id: user.id,
              gecko_id: crypto.gecko_id
            }
          end

        before do
            allow(Crypto).to receive(:find_by).and_return(crypto)
            request.headers['Authorization'] = "Bearer #{authorization}"
            post :create, params: {transaction: transaction_params}
        end
  
        it 'creates a new transaction and updates user balance' do
            expect(response).to have_http_status(:unprocessable_entity) 
            expect(JSON.parse(response.body)['errors']).to include('Insufficient coins')
       
        end
      end

      context 'when coin exists for trading but invalid quantity and value' do
        let(:user) { create(:user, :trader_with_balance) }
        let!(:user_crypto) { create(:user_crypto,:with_quantity, user: user, crypto: crypto) }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'trader') }
        let(:transaction_params) do
            {
              transaction_type: 'sell',
              quantity: -101,
              total_value: -1000,
              user_id: user.id,
              gecko_id: crypto.gecko_id
            }
          end

        before do
            allow(Crypto).to receive(:find_by).and_return(crypto)
            request.headers['Authorization'] = "Bearer #{authorization}"
            post :create, params: {transaction: transaction_params}
        end
  
        it 'creates a new transaction and updates user balance' do
            expect(response).to have_http_status(:unprocessable_entity) 
            expect(JSON.parse(response.body)['errors']).to include('Invalid input, cannot be blank or zero.')
       
        end
      end
  
      context 'when coin does not exist for trading' do
        let(:user) { create(:user, :trader_with_balance) }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'trader') }
        let(:transaction_params) do
            {
              transaction_type: 'buy',
              quantity: 1,
              total_value: 100,
              user_id: user.id,
              gecko_id: 'bitcoin'
            }
          end

        before do
          allow(Crypto).to receive(:find_by).and_return(nil)
          request.headers['Authorization'] = "Bearer #{authorization}"
          post :create, params: {transaction: transaction_params}
        end
  
        it 'returns an error message' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['errors']).not_to be_empty
        end
      end
    end

    describe 'GET #index' do
        let!(:transactions) { create_list(:transaction, 3) }
        let(:user) { User.find_by(email:'admin@coinswift.com') }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'admin') }
    
        before do
            request.headers['Authorization'] = "Bearer #{authorization}"
            get :index
        end
    
        it 'returns a list of transactions' do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['transactions'].count).to eq(3)
        end
    end

    describe 'GET #show' do
        let(:user) { User.find_by(email:'admin@coinswift.com') }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'admin') }
    
        before do
            request.headers['Authorization'] = "Bearer #{authorization}"
        end

        context 'when user has transactions' do
            let(:trader) {create(:user, :trader_with_balance)}
            let!(:transactions) { create_list(:transaction, 2, user: trader) }
        
            before { get :show, params: { id: trader.id } }
        
            it 'returns the user transactions' do
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)['transactions'].count).to eq(2)
            end
        end
    
        
    end

  end
  
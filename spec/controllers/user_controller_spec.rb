require 'rails_helper'
require_relative '../../app/models/user'
require_relative '../../app/models/role'
require_relative '../../app/models/user_role'
require_relative './application_controller_spec'

RSpec.describe Api::V1::UsersController, type: :controller do
    describe 'POST #create' do
        context 'when passwords match' do

            let(:user_params) do
                {
                  user: FactoryBot.attributes_for(
                    :user,
                    email: 'test@example.com',
                    phone_number: '+639123456789',
                    password: 'password',
                    password_confirmation: 'password'
                  )
                }
              end
            
              it 'creates a new user' do
                post :create, params: user_params
                expect(response).to have_http_status(:ok)
                expect(User.count).to eq(2)
                expect(User.last.email).to eq(user_params[:user][:email])
              end
    
            it 'assigns the default role to the user' do
                post :create, params: user_params
                expect(response).to have_http_status(:ok)
                user = User.last
                expect(user.roles.first.name).to eq('trader')
            end
    
            it 'returns a success message and the created user' do
                post :create, params: user_params
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to include(
                    'messages' => ['Verification code sent'],
                    'user' => a_hash_including(
                    'email' => user_params[:user][:email]
                    )
                )
            end

        end
    
        context 'when passwords do not match' do
            let(:user_params) { FactoryBot.attributes_for(:user, password_confirmation: 'different_password') }
        
            it 'returns an error message' do
                post :create, params: { user: user_params }
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)).to include(
                'errors' => ['Passwords do not match!']
                )
            end
        end
    end

    describe 'GET #show' do
        let(:user) { create(:user, :trader) }
    
        it 'returns the serialized user' do
            allow(controller).to receive(:current_user).and_return(user)
            get :show, params: { id: user.id }
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)).to include(
                'user' => a_hash_including(
                'id' => user.id,
                'email' => user.email,
                'phone_number' => user.phone_number,
                'verified' => user.verified,
                'approved' => user.approved,
                'balance' => user.balance
                )
            )
        end
    end

    describe 'PATCH #update' do
        let(:user)  { create(:user, :trader) }
        let(:new_email) { 'newemail@example.com' }
        let(:new_phone_number) { '+639456421993' }

        before do
            allow_any_instance_of(Twilio::SmsService).to receive(:send_msg)
            allow(Rails.cache).to receive(:write)         
        end
      
    
        context 'with valid attributes' do
            let(:valid_attributes) { { email: new_email, phone_number: new_phone_number } }
        
            it 'updates the user attributes' do
                allow(controller).to receive(:current_user).and_return(user)
                patch :update, params: { id: user.id, user: valid_attributes }
                expect(response).to have_http_status(:ok)
                user.reload
                expect(user.email).to eq(new_email)
                expect(user.phone_number).to eq(new_phone_number)
            end
    
            it 'returns the serialized updated user' do
                allow(controller).to receive(:current_user).and_return(user)
                patch :update, params: { id: user.id, user: valid_attributes }
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to include(
                'user' => a_hash_including(
                    'id' => user.id,
                    'email' => new_email,
                    'phone_number' => new_phone_number,
                    'verified' => user.verified,
                    'approved' => user.approved,
                    'balance' => user.balance
                )
                )
            end
        end
    
        context 'with invalid attributes' do
            let(:invalid_attributes) { { email: '', phone_number: '' } }
        
            it 'does not update the user attributes' do
                allow(controller).to receive(:current_user).and_return(user)
                patch :update, params: { id: user.id,user: invalid_attributes }
                expect(response).to have_http_status(:unprocessable_entity)
                user.reload
                expect(user.email).not_to eq('')
                expect(user.phone_number).not_to eq('')
            end
        
            it 'returns the errors as JSON' do
                allow(controller).to receive(:current_user).and_return(user)
                patch :update, params: { id: user.id,user: invalid_attributes }
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)).to include(
                'errors' => be_an(Array)
                )
            end
        end
    end

    
    describe 'GET #index_owned_cryptos' do
        let(:user) { create(:user, :trader) }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'trader') }

        before do
            
            request.headers['Authorization'] = "Bearer #{authorization}"
        end
        
        it 'returns the owned cryptocurrencies' do
            
            
            existing_cryptos = Crypto.limit(3) 
            user_cryptos = []
            
            existing_cryptos.each do |crypto|
                user_crypto = create(:user_crypto, user: user, crypto: crypto)
                user_cryptos << user_crypto
            end
            
            cryptos = user_cryptos.map(&:crypto)
            get :index_owned_cryptos
      
      
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)['cryptos']).to be_an(Array)
            expect(JSON.parse(response.body)['cryptos'].length).to eq(3)
        end
    end

    describe 'GET #show_owned_crypto' do
        let(:user) { create(:user) }
        let(:crypto) { Crypto.find_by(id: 980) }
      
        context 'when the user owns the crypto' do
            let!(:user_crypto) { create(:user_crypto, user: user, crypto: crypto) }
        
            before do
                allow(controller).to receive(:current_user).and_return(user)
                get :show_owned_crypto, params: { id: crypto.id }
            end
        
            it 'returns the owned crypto' do
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)['crypto']).not_to be_nil
            end
        end
      
        context 'when the user does not own the crypto' do
            before do
                allow(controller).to receive(:current_user).and_return(user)
                get :show_owned_crypto, params: { id: crypto.id }
            end
        
            it 'returns an error message' do
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)['errors']).to include('Crypto not owned')
            end
        end
    end

    describe 'GET #index_transactions' do
        let(:user) { create(:user) }
      
        before do
            allow(controller).to receive(:current_user).and_return(user)
            create_list(:transaction, 3, user: user)
            get :index_transactions
        end
      
        it 'returns the user\'s transactions' do
            transactions = user.transactions
        
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)['transactions']).to be_an(Array)
            expect(JSON.parse(response.body)['transactions'].length).to eq(transactions.count)
        end
    end

    describe 'PATCH #update_watchlist' do
        let(:user) { create(:user) }
        let(:crypto) { Crypto.find_by(id: 9635) }
        let(:watchlist_params) { { gecko_id: crypto.gecko_id, on_watchlist: true } }
      
        before do
            allow(controller).to receive(:current_user).and_return(user)
            patch :update_watchlist, params: { watchlist: watchlist_params }
        end
      
        context 'when UserCrypto is created' do
            it 'returns a success message' do
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)['messages']).to eq(['UserCrypto updated successfully'])
            end
      
            it 'creates a new UserCrypto record' do
                expect(UserCrypto.count).to eq(1)
                expect(UserCrypto.first.user_id).to eq(user.id)
                expect(UserCrypto.first.crypto_id).to eq(crypto.id)
                expect(UserCrypto.first.on_watchlist).to eq(true)
                expect(UserCrypto.first.quantity).to eq(0)
            end
        end
      
        context 'when UserCrypto is updated' do
            let!(:user_crypto) { create(:user_crypto, user: user, crypto: crypto) }
        
            it 'returns a success message' do
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)['messages']).to eq(['UserCrypto updated successfully'])
            end
        
            it 'updates the existing UserCrypto record' do
                expect(UserCrypto.count).to eq(2)
                expect(UserCrypto.first.user_id).to eq(user.id)
                expect(UserCrypto.first.crypto_id).to eq(crypto.id)
                expect(UserCrypto.first.on_watchlist).to eq(true)
                expect(UserCrypto.first.quantity).to eq(0)
            end
        end
      
        context 'when there are validation errors' do
            let(:watchlist_params) { { gecko_id: 'nonexisting_id', on_watchlist: true } }
        
            it 'returns an error message' do
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)['errors']).not_to be_empty
            end
        
            it 'does not create a new UserCrypto record' do
                expect(UserCrypto.count).to eq(0)
            end
        end

      end
      
end
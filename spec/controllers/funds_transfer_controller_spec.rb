require 'rails_helper'
require_relative '../../app/models/user'
require_relative '../../app/models/role'
require_relative '../../app/models/user_role'
require_relative './application_controller_spec'

RSpec.describe Api::V1::FundsTransfersController, type: :controller do
    
  
    describe 'POST #create' do
        let(:user) { create(:user, :trader_with_balance) }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'trader') }
    
        before do
            allow(controller).to receive(:current_user).and_return(user)
            request.headers['Authorization'] = "Bearer #{authorization}"
        end

        context 'depositing with valid amount' do
            let(:params) do
                {
                    funds_transfer: {
                        transaction_type: 'deposit',
                        amount: 100
                    }
                }
            end

            context 'and trader deposits succesfully' do 

                before do 
                    post :create, params: params
                end

                it 'updates the user balance and returns success' do
                    expect(response).to have_http_status(:accepted)
                    expect(JSON.parse(response.body)['messages']).to include(
                      "An amount of 100.0 has been deposited to your account"
                    )
                    expect(user.reload.balance).to eq(5100) 
                end          
            end

            context 'and the deposit fails' do 

                before do 
                    allow(user).to receive(:update).and_return(false)
                    post :create, params: params
                end

                it 'it returns an error' do
                    expect(response).to have_http_status(:unprocessable_entity)
                    expect(JSON.parse(response.body)['errors']).to include(
                        'Failed to update the balance'
                    )
                end          
            end           
        end

        context 'withdrawing with a valid amount' do
            let(:params) do
                {
                    funds_transfer: {
                        transaction_type: 'withdraw',
                        amount: 100
                    }
                }
            end

            context 'and trader withdraws succesfully' do 

                before do 
                    post :create, params: params
                end

                it 'updates the user balance and returns success' do
                    expect(response).to have_http_status(:accepted)
                    expect(JSON.parse(response.body)['messages']).to include(
                      "An amount of 100.0 has been withdrawed to your account. Balance: 4900.0"
                    )
                    expect(user.reload.balance).to eq(4900) 
                end          
            end

            context 'and the withdraw fails' do 

                before do 
                    allow(user).to receive(:update).and_return(false)
                    post :create, params: params
                end

                it 'it returns an error' do
                    expect(response).to have_http_status(:unprocessable_entity)
                    expect(JSON.parse(response.body)['errors']).to include(
                        'Failed to update the balance'
                    )
                end          
            end           

            context 'and trader has insufficient funds' do 
                let(:invalid_withdraw) do
                    {
                        funds_transfer: {
                            transaction_type: 'withdraw',
                            amount: 5200
                        }
                    }
                end

                before do 
                    allow(user).to receive(:update).and_return(false)
                    post :create, params: invalid_withdraw
                end

                it 'it returns an error' do
                    expect(response).to have_http_status(:unprocessable_entity)
                    expect(JSON.parse(response.body)['errors']).to include(
                        'Insufficient balance'
                    )
                end          
            end           
        end
    
        context 'with an invalid amount' do
            let(:params) do
            {
                funds_transfer: {
                transaction_type: 'withdraw',
                amount: '-100'
                }
            }
            end
    
            before { post :create, params: params }
    
            it 'returns an error message' do
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)['errors']).to eq(['invalid amount'])
            end
        end
    end

    describe 'GET #index' do
        let(:user) { create(:user, :trader_with_balance) }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'trader') }
    
        before do
            allow(controller).to receive(:current_user).and_return(user)
            request.headers['Authorization'] = "Bearer #{authorization}"
        end

        it 'returns a list of funds transfers' do
          funds_transfer1 = create(:funds_transfer)
          funds_transfer2 = create(:funds_transfer)
          
          get :index
          
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          funds_transfers = json_response['funds_transfers']
          
          expect(funds_transfers.length).to eq(2)
          
          funds_transfer1_json = funds_transfers.find { |ft| ft['id'] == funds_transfer1.id }
          funds_transfer2_json = funds_transfers.find { |ft| ft['id'] == funds_transfer2.id }
          
          expect(funds_transfer1_json).not_to be_nil
          expect(funds_transfer1_json['transaction_type']).to eq(funds_transfer1.transaction_type)
          expect(funds_transfer1_json['amount']).to eq('100.0')
          
          expect(funds_transfer2_json).not_to be_nil
          expect(funds_transfer2_json['transaction_type']).to eq(funds_transfer2.transaction_type)
          expect(funds_transfer2_json['amount']).to eq('100.0')
        end
    end

    describe 'GET #show' do
        let(:user) { create(:user, :trader_with_balance) }
        let(:authorization) { JwtToken.new.encode_token(user_id: user.id, role: 'trader') }
    
        before do
            allow(controller).to receive(:current_user).and_return(user)
            request.headers['Authorization'] = "Bearer #{authorization}"
        end

        context 'when funds transfer exists' do
          it 'returns the requested funds transfer' do
            funds_transfer = create(:funds_transfer)
            
            get :show, params: { id: funds_transfer.id }
            
            expect(response).to have_http_status(:ok)
            json_response = JSON.parse(response.body)
            funds_transfer_json = json_response['funds_transfer']
            
            expect(funds_transfer_json).not_to be_nil
            expect(funds_transfer_json['id']).to eq(funds_transfer.id)
            expect(funds_transfer_json['transaction_type']).to eq(funds_transfer.transaction_type)
            expect(funds_transfer_json['amount']).to eq('100.0')
          end
        end
        
        context 'when funds transfer does not exist' do
          it 'returns an error message' do
            non_existent_id = 9999
            
            get :show, params: { id: non_existent_id }
            
            expect(response).to have_http_status(:not_found)
            json_response = JSON.parse(response.body)
            
            expect(json_response['errors']).to eq(['Transfer not found'])
          end
        end
      end


end
require 'rails_helper'
require_relative '../../app/models/user'
require_relative '../../app/models/role'
require_relative '../../app/models/user_role'
require_relative './application_controller_spec'

RSpec.describe Api::V1::AdminController, type: :controller do

  let(:admin_user) { User.find_by(email: 'admin@coinswift.com') }
  let(:authorization) { JwtToken.new.encode_token(user_id: admin_user.id, role: 'admin') }

  describe "POST #create_trader" do
    context "with valid params" do
      it "creates a new trader account" do
        trader_params = attributes_for(:user, :trader)
        request.headers['Authorization'] = "Bearer #{authorization}"
        post :create_trader, params: { trader: trader_params }
        expect(response).to have_http_status(:created)
        response_json = JSON.parse(response.body)
        expect(response_json).to include("status" => ["Trader account for #{trader_params[:email]} successfully created."])
      end
    end

    context "when not authorized" do
      it "returns unauthorized status" do
        trader_params = attributes_for(:user, :trader)
        post :create_trader, params: { trader: trader_params }
        expect(response).to have_http_status(:unauthorized)
        response_json = JSON.parse(response.body)
        expect(response_json).to include("message" => "Please log in")
      end
    end

    context "when not an admin" do
      it "returns unauthorized status" do
        trader_params = attributes_for(:user, :trader)
        user = create(:user)
        user_jwt = JwtToken.new.encode_token(user_id: user.id, role: 'trader') 
        request.headers['Authorization'] = "Bearer #{user_jwt}"
        post :create_trader, params: { trader: trader_params }
        expect(response).to have_http_status(:unauthorized)
        response_json = JSON.parse(response.body)
        expect(response_json).to include("errors" => ["no admin privileges"])
      end
    end
  end

  describe Api::V1::AdminController do
    describe "PATCH #update_trader" do
      let(:trader) { create(:user, :trader) }

      before do
        request.headers['Authorization'] = "Bearer #{authorization}"
        get :show_trader, params: { id: trader.id }
      end
  
      context "with valid parameters" do
        it "updates the trader's information" do
          new_email = "new_email@example.com"
          new_phone_number = "+639456874986"
  
          patch :update_trader, params: { id: trader.id, trader: { email: new_email, phone_number: new_phone_number } }
  
          expect(response).to have_http_status(:ok)
          expect(trader.reload.email).to eq(new_email)
          expect(trader.reload.phone_number).to eq(new_phone_number)
        end
      end
  
      context "with invalid parameters" do
        it "returns an error message" do
          invalid_phone = "6+59fds6++"
  
          patch :update_trader, params: { id: trader.id, trader: { phone_number: invalid_phone } }
  
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"]).to include("Phone number is in invalid number.")
          expect(trader.reload.phone_number).not_to eq(invalid_phone)
        end
      end
    end
  end

  describe "GET #show_trader" do
    context "when the trader exists" do
      let(:trader) { create(:user, :trader) }
    
      before do
        request.headers['Authorization'] = "Bearer #{authorization}"
        get :show_trader, params: { id: trader.id }
      end
    
      it "returns the trader's details" do
        expect(response).to have_http_status(:ok)
        response_json = JSON.parse(response.body)
        expect(response_json).to include("trader" => { "id" => trader.id, "email" => trader.email, "approved"=>nil, "verified"=>nil, "phone_number"=> trader.phone_number, "balance" => nil })
      end
    end

    context "when the trader does not exist" do
      before do
        request.headers['Authorization'] = "Bearer #{authorization}"
        get :show_trader, params: { id: 1234 }
      end

      it "returns an error message" do
        expect(response).to have_http_status(:not_found)
        response_json = JSON.parse(response.body)
        expect(response_json).to include("errors" => "User not found")
      end
    end
  end

  describe "GET #index_traders" do
    context "when there are traders" do
      let!(:traders) { create_list(:user, 3, :trader) }

      before do
        request.headers['Authorization'] = "Bearer #{authorization}"
        get :index_traders
      end

      it "returns a list of traders" do
        expect(response).to have_http_status(:ok)
        response_json = JSON.parse(response.body)
        expect(response_json["traders"].length).to eq(3)
      end
    end

    context "when there are no traders" do
      before do
        request.headers['Authorization'] = "Bearer #{authorization}"
        get :index_traders
      end

      it "returns an error message" do
        expect(response).to have_http_status(:not_found)
        response_json = JSON.parse(response.body)
        expect(response_json).to include("errors" => "Traders not found")
      end
    end
  end

  describe 'GET #pending_approval_traders' do
    let!(:traders) { create_list(:user, 3, :trader, approved: nil) }
    let!(:approved_trader) { create(:user, :trader, approved: true) }

    before do
      request.headers['Authorization'] = "Bearer #{authorization}"
      get :index_traders
    end

    it 'returns a list of traders pending approval' do
      get :pending_approval_traders

      expect(response).to have_http_status(:ok)
      response_json = JSON.parse(response.body)
      expect(response_json['traders'].length).to eq(3)

      traders.each_with_index do |trader, index|
        expect(response_json['traders'][index]['id']).to eq(trader.id)
        expect(response_json['traders'][index]['email']).to eq(trader.email)
        expect(response_json['traders'][index]['approved']).to be_nil
        expect(response_json['traders'][index]['verified']).to be_nil
        expect(response_json['traders'][index]['phone_number']).to eq(trader.phone_number)
      end
    end
  end

  describe 'POST #approve_trader' do
    let(:trader) { create(:user, :trader) }

    before do
      request.headers['Authorization'] = "Bearer #{authorization}"
      get :index_traders
    end

    it 'approves a trader for trading' do
      post :approve_trader, params: { id: trader.id }

      expect(response).to have_http_status(:ok)
      response_json = JSON.parse(response.body)
      expect(response_json['message']).to eq('User approved for trading')

      trader.reload
      expect(trader.approved).to be_truthy
    end
  end

end

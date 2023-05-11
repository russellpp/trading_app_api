require 'rails_helper'
require_relative '../../app/models/user'
require_relative '../../app/models/role'
require_relative '../../app/models/user_role'
require_relative './application_controller_spec'

RSpec.describe Api::V1::AuthController, type: :controller do

    describe "POST #login" do
        let(:user) { create(:user, :trader) }
        before do
            allow_any_instance_of(Twilio::SmsService).to receive(:send_msg) 
        end
  
      context "with valid credentials and verified account" do
        let(:user) { create(:user, :valid_trader)  }
        it "logs in the user and returns the authentication token" do
          post :login, params: { user: { email: user.email, password: user.password } }
  
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)["token"]).not_to be_nil
          expect(JSON.parse(response.body)["user"]["email"]).to eq(user.email)
        end
      end

      context "with valid credentials and unverified account" do
        it "logs in the user and returns the authentication token" do
          post :login, params: { user: { email: user.email, password: user.password } }
  
          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)["errors"]).to include("Must be verified before logging in, verification code sent to #{user.phone_number}")
        end
      end
  
      context "with blank email or password" do
        it "returns an error message" do
          post :login, params: { user: { email: "", password: user.password } }
  
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"]).to include("Email or password cannot be blank")
        end
      end
  
      context "with incorrect credentials" do
        it "returns an error message" do
          post :login, params: { user: { email: user.email, password: "incorrect_password" } }
  
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"]).to include("Incorrect email or password")
        end
      end
    end

    describe "POST #confirm_verification" do
        let(:user) { create(:user) }

        before do
            allow_any_instance_of(Twilio::SmsService).to receive(:send_msg)
            allow(Rails.cache).to receive(:write)         
        end
    
        context "with valid verification code" do
          it "returns success message and status 200" do
            allow(Rails.cache).to receive(:read).and_return(980987) 
            post :confirm_verification, params: { verify: { email: user.email, verification_code: 980987 } }
            

            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)["status"]).to include("Account verified")
          end
        end
    
        context "with invalid verification code" do
          it "returns error message and status 422" do
            allow(Rails.cache).to receive(:read).and_return(980987) 
            post :confirm_verification, params: { verify: { email: user.email, verification_code: 968574 } }
    
            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)["errors"]).to include("Incorrect code")
          end
        end
    
        context "with expired code", skip_cache_read: true do
          it "returns error message and status 422" do
            allow(Rails.cache).to receive(:read).and_return(nil)
            post :confirm_verification, params: { verify: { email: user.email, verification_code: 123456 } }
    
            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)["errors"]).to include("Code has expired. New verification code have been sent to #{user.phone_number}")
          end
        end
    end

    describe "POST #send_code" do
        let(:user) { create(:user) }

        before do
            allow_any_instance_of(Twilio::SmsService).to receive(:send_msg)
            allow(Rails.cache).to receive(:write)         
        end
    
        context "with verification send_type" do
          it "sends verification code and returns success message and status 200" do
            post :send_code, params: { send: { phone_number: user.phone_number, send_type: "verification" } }
    
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)["messages"]).to eq(["Verification code have been sent to #{user.phone_number}"])
          end
        end
    
        context "with reset send_type" do
          it "sends reset code and returns success message and status 200" do
            post :send_code, params: { send: { phone_number: user.phone_number, send_type: "reset" } }
    
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)["messages"]).to eq(["Password reset code have been sent to #{user.phone_number}"])
          end
        end
    
        context "with invalid phone number" do
          it "returns error message and status 422" do
            post :send_code, params: { send: { phone_number: "+123456789", send_type: "verification" } }
    
            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)["errors"]).to eq(["Phone number is not associated with any accounts"])
          end
        end
    end

    describe "POST #password_reset" do
        let(:user) { create(:user) }

        before do
            allow_any_instance_of(Twilio::SmsService).to receive(:send_msg)
            allow(Rails.cache).to receive(:write)         
        end

        context "with valid phone number" do
          it "starts password reset and returns success message" do
            expect_any_instance_of(User).to receive(:start_password_reset)
            post :password_reset, params: { password_reset: { phone_number: user.phone_number } }
    
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)["message"]).to include("Password reset code have been sent to #{user.phone_number}")
          end
        end
    
        context "with invalid phone number" do
          it "returns error message" do
            post :password_reset, params: { password_reset: { phone_number: "1234567890" } }
    
            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)["errors"]).to include("Phone number is not associated with any accounts")
          end
        end
    end
    
    describe "POST #confirm_password_reset" do
        let(:user) { create(:user) }

        before do
            allow_any_instance_of(Twilio::SmsService).to receive(:send_msg)
            allow(Rails.cache).to receive(:write)         
        end

        context "with matching passwords and valid code" do
            it "confirms password reset and returns success message" do
                allow(Rails.cache).to receive(:read).and_return(111222) 
                post :confirm_password_reset, params: { reset_confirm: { phone_number: user.phone_number, code: 111222, password: "newpassword", password_confirmation: "newpassword" } }
        
                expect(response).to have_http_status(:accepted)
                expect(JSON.parse(response.body)["status"]).to include("Password has been reset")
            end
        end
      
        context "with matching passwords and invalid code" do
            it "confirms password reset and returns success message" do
                allow(Rails.cache).to receive(:read).and_return(980987) 
                post :confirm_password_reset, params: { reset_confirm: { phone_number: user.phone_number, code: 111987, password: "newpassword", password_confirmation: "newpassword" } }
        
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)["errors"]).to include('Incorrect code')
            end
        end
    
        context "with non-matching passwords" do
            it "returns error message" do
                allow(Rails.cache).to receive(:read).and_return(980987) 
                post :confirm_password_reset, params: { reset_confirm: { phone_number: user.phone_number, code: 980987, password: "newpassword", password_confirmation: "differentpassword" } }
        
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)["errors"]).to include("Passwords do not match")
            end
        end
    
        context "with invalid phone number" do
            it "returns error message" do
                allow(Rails.cache).to receive(:read).and_return(980987) 
                post :confirm_password_reset, params: { reset_confirm: { phone_number: "1234567890", code: "123456", password: "newpassword", password_confirmation: "newpassword" } }
        
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)["errors"]).to include("Phone number is not associated with any accounts")
            end
        end

        context "with valid phone number and expired code" do
            it "returns error message" do
                allow(Rails.cache).to receive(:read).and_return(nil) 
                post :confirm_password_reset, params: { reset_confirm: { phone_number: user.phone_number, code: "123456", password: "newpassword", password_confirmation: "newpassword" } }
        
                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)["errors"]).to include("Code has expired. New reset code have been sent to #{user.phone_number}")
            end
        end
      end

end
require 'rails_helper'
require_relative '../../app/controllers/application_controller'
require_relative '../services/jwt_token_spec'

RSpec.describe ApplicationController, type: :controller do
    describe '#auth_header' do
      context 'when Authorization header is present' do
        it 'returns the authorization header' do
          request.headers['Authorization'] = 'Bearer token123'
          expect(controller.auth_header).to eq 'Bearer token123'
        end
      end
  
      context 'when Authorization header is not present' do
        it 'returns nil' do
          expect(controller.auth_header).to be_nil
        end
      end
    end
  
    describe '#current_user' do
      context 'when the JWT token is valid' do
        let(:user) { create(:user) }
        let(:jwt_token) { JwtToken.new.encode_token(user_id: user.id) }
  
        before do
          request.headers['Authorization'] = "Bearer #{jwt_token}"
        end
  
        it 'returns the current user' do
          expect(controller.current_user).to eq user
        end
      end
  
      context 'when the JWT token is invalid' do
        before do
          request.headers['Authorization'] = 'Bearer invalid_token'
        end
  
        it 'returns nil' do
          expect(controller.current_user).to be_nil
        end
      end
    end
  
    describe '#logged_in?' do
      context 'when the user is logged in' do
        let(:user) { create(:user) }
        let(:jwt_token) { JwtToken.new.encode_token(user_id: user.id) }
  
        before do
          request.headers['Authorization'] = "Bearer #{jwt_token}"
        end
  
        it 'returns true' do
          expect(controller.logged_in?).to be_truthy
        end
      end
  
      context 'when the user is not logged in' do
        it 'returns false' do
          expect(controller.logged_in?).to be_falsey
        end
      end
    end
  
    describe '#authorized' do
      context 'when the user is logged in' do
        let(:user) { create(:user) }
        let(:jwt_token) { JwtToken.new.encode_token(user_id: user.id, role: 'admin') }
  
        before do
          request.headers['Authorization'] = "Bearer #{jwt_token}"
        end
  
        it 'does not render an unauthorized message' do
          expect(controller).not_to receive(:render).with(json: { message: 'Please log in' }, status: :unauthorized)
          controller.authorized
        end
      end
  
      context 'when the user is not logged in' do
        it 'renders an unauthorized message' do
          expect(controller).to receive(:render).with(json: { message: 'Please log in' }, status: :unauthorized)
          controller.authorized
        end
      end
    end
  
    describe '#admin_role' do
      context 'when the JWT token is valid' do
        let(:jwt_token) { JwtToken.new.encode_token(role: 'admin') }
  
        before do
          request.headers['Authorization'] = "Bearer #{jwt_token}"
        end
  
        it 'returns the admin role' do
          expect(controller.admin_role).to eq 'admin'
        end
      end
  
      context 'when the JWT token is invalid' do
        before do
          request.headers['Authorization'] = 'Bearer invalid_token'
        end
  
        it 'returns nil' do
          expect(controller.admin_role).to be_nil
        end
      end
    end
  
    describe '#is_admin?' do
      context 'when the user is an admin' do
        let(:jwt_token) { JwtToken.new.encode_token(role: 'admin') }
        before do
            request.headers['Authorization'] = "Bearer #{jwt_token}"
          end
        
          it 'does not render an unauthorized message' do
            expect(controller).not_to receive(:render).with(json: { errors: ['no admin privileges'] }, status: :unauthorized)
            controller.is_admin?
          end
        end
        
        context 'when the user is not an admin' do
          let(:jwt_token) { JwtToken.new.encode_token(role: 'user') }
        
          before do
            request.headers['Authorization'] = "Bearer #{jwt_token}"
          end
        
          it 'renders an unauthorized message' do
            expect(controller).to receive(:render).with(json: { errors: ['no admin privileges'] }, status: :unauthorized)
            controller.is_admin?
          end
        end

    end
end

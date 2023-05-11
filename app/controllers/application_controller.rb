class ApplicationController < ActionController::Base

	before_action :authorized 
    protect_from_forgery with: :null_session

    def auth_header
        # { 'Authorization': 'Bearer <token>' }
        request.headers['Authorization']
    end 

    def current_user
        jwtToken = JwtToken.new
        decode = jwtToken.decoded_token(auth_header)
        if decode
            user_id = decode['user_id']
            @user = User.find_by(id: user_id)
        end
    end

    def logged_in?
        !!current_user
    end
  
    def authorized
        render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
    end

    def admin_role
        jwtToken = JwtToken.new
        decode = jwtToken.decoded_token(auth_header)
        if decode 
            role = decode['role']
            return role
        end
    end

    def is_admin?
        render json: {errors: ["no admin privileges"]}, status: :unauthorized unless admin_role == 'admin'
    end

    def approved
        render json: { errors: ['Cannot do action. Get your account approved first.'] }, status: :unauthorized unless current_user.approved
    end



end

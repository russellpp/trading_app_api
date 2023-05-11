module Api 
	module V1
		class SessionsController < ApplicationController
			
			skip_before_action :authorized, only: [:create]

			def create
				if user_login_params[:email].blank? || user_login_params[:password].blank?
				     render json: { error: ['Email or password cannot be blank'] }, status: :unprocessable_entity
					 
				else 
					@user = User.find_by(email: user_login_params[:email])
					
					
					if @user && @user.authenticate(user_login_params[:password]) && is_verified?(@user)
						jwtToken = JwtToken.new
						expiry = Time.now.to_i + 30 * 60
						token  = jwtToken.encode_token(user_id: @user.id, role: @user.roles[0].name, exp: expiry)	

						if token
							if is_admin?
								render json: { user: UserSerializer.new(@user), jwt: token, is_admin?: true}, status: :accepted
							else
								render json: { user: UserSerializer.new(@user), jwt: token }, status: :accepted
							end
						else
							render json: {errors: ['Authentication token has expired. Please login again.']}, status: :unauthorized
						end
						
					elsif !is_verified?(@user)
						render json: { errors: ['Must be verified before logging in'] }, status: :unauthorized
					else
						render json: { errors: ['Incorrect email or password'] }, status: :unauthorized
					end
				end
			end

            def destroy
				session[:user_id] = nil
				render json: { message: 'Logged out' }, status: :ok
			end
			  
			  
			private
		
			def user_login_params
				params.require(:user).permit(:email, :password)
			end
			  
			def is_verified?(user)
				!!user.verified
			end

			def is_admin?
				if @user.roles[0].name == 'admin'
					return true
				else
					return false
				end
			end


		end
	end
end

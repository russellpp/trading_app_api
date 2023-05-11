module Api 
	module V1
		class AuthController < ApplicationController
			skip_before_action :authorized, only: [:confirm_verification, :login, :password_reset, :confirm_password_reset, :send_code]
			
			def login
				if user_login_params[:email].blank? || user_login_params[:password].blank?
				     render json: { errors: ['Email or password cannot be blank'] }, status: :unprocessable_entity
					 
				else 
					@user = User.find_by(email: user_login_params[:email])
					
					
					if @user && @user.authenticate(user_login_params[:password])
						jwtToken = JwtToken.new
						expiry = Time.now.to_i + 30 * 60
						token  = jwtToken.encode_token(user_id: @user.id, role: @user.roles[0].name, exp: expiry)	

						if !is_verified?(@user)
							#send verification sms
							@user.start_verification

							render json: { errors: ["Must be verified before logging in, verification code sent to #{@user.phone_number}"], redirect_to_verify: true }, status: :not_found

						elsif token
							if is_admin?
								render json: { user: UserSerializer.new(@user), token: token, is_admin: true}, status: :ok
							else
								render json: { user: UserSerializer.new(@user), token: token }, status: :ok
							end
						else
							render json: {errors: ['Authentication token has expired. Please login again.']}, status: :unprocessable_entity
						end
						
					else
						render json: { errors: ['Incorrect email or password'] }, status: :unprocessable_entity
					end
				end
			end
			  
			def confirm_verification
				@user = User.find_by(email: user_verify_params[:email])
				status = @user.check_verification(user_verify_params[:verification_code])

				render json: status[:message], status: status[:status]				
			end

			def send_code
				@user = User.find_by(phone_number: send_params[:phone_number])
				send_type = send_params[:send_type]
				if @user
					if send_type == "verification" 
						@user.start_verification
						render json: { messages: ["Verification code have been sent to #{@user.phone_number}"] }, status: :ok
					elsif send_type == "reset"
						#generate code
						@user.start_password_reset
						#send code
						render json: { messages: ["Password reset code have been sent to #{@user.phone_number}"] }, status: :ok
					end
				else
					render json: { errors: ['Phone number is not associated with any accounts'] }, status: :unprocessable_entity
				end
				
			end

			def password_reset
				@user = User.find_by(phone_number: password_reset_params[:phone_number])

				if @user
					#generate code
				  	@user.start_password_reset

					#send code
				  	render json: { message: ["Password reset code have been sent to #{@user.phone_number}"] }, status: :ok
				else
					render json: { errors: ['Phone number is not associated with any accounts'] }, status: :unprocessable_entity
				end
			end

			def confirm_password_reset
				@user = User.find_by(phone_number: reset_confirm_params[:phone_number])

				if reset_confirm_params[:password] != reset_confirm_params[:password_confirmation]
					render json: { errors: ['Passwords do not match'] }, status: :unprocessable_entity
				elsif @user 
					status = @user.confirm_password_reset(reset_confirm_params[:code], reset_confirm_params[:password])
					render json: status[:message], status: status[:status]	
				else
					render json: { errors: ['Phone number is not associated with any accounts'] }, status: :unprocessable_entity
				end
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

			def user_verify_params
				params.require(:verify).permit(:email, :phone_number, :verification_code)
			end

			def password_reset_params
				params.require(:password_reset).permit(:phone_number)
			end
			  
			def reset_confirm_params
				params.require(:reset_confirm).permit(:phone_number, :code, :password, :password_confirmation)
			end

			def send_params
				params.require(:send).permit(:phone_number, :send_type)
			end

		end
	end
end

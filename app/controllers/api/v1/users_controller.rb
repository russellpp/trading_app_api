module Api
	module V1
		class UsersController < ApplicationController
			skip_before_action :authorized, only: [:create]
			skip_before_action :verify_authenticity_token, only: [:create]
			before_action :authorized, only: [:update, :show, :index_owned_cryptos, :show_owned_crypto, :index_transactions, :update_watchlist]
			

			def create
				if user_params[:password] != user_params[:password_confirmation]
					render json: {errors: ['Passwords do not match!']}, status: :unprocessable_entity
				else 
					@user = User.create(user_params)
					def_role = Role.find_by(name: "trader")

					
					if @user.valid?
						@user.user_roles.create(role: def_role)
						
						#send verification sms
						#verification = Verification.new(rec_phone_number: user_params[:phone_number])
						#verification.start_verification

						#token  = jwtToken.encode_token(user_id: @user.id, role: @user.roles[0].name)

						render json: {messages: ['Verification code sent'], user: UserSerializer.new(@user)}, status: :ok

					else
						render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
					end
				end
			end

			def show
				user = current_user
				render json: {user: UserSerializer.new(user)}, status: :ok
			end

			def update
				user = current_user
				if user.update(user_params)
					render json: { user: UserSerializer.new(user) }, status: :ok
				else
					render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
				end
			end
			
	
			def index_owned_cryptos
				user_cryptos = UserCrypto.where(user_id: current_user.id)
				cryptos = user_cryptos.map(&:crypto)
				render json: { cryptos: cryptos.map { |crypto| CryptoSerializer.new(crypto, scope: { user_id: current_user.id }, except: [:quantity, :on_watchlist]) } }, status: :ok
			end

			def show_owned_crypto
				@crypto = Crypto.find_by(id: params[:id])
				user_crypto = UserCrypto.find_by(user_id: current_user.id, crypto_id: @crypto.id)
				
				if user_crypto
					render json: {crypto: CryptoSerializer.new(@crypto, scope: {user_id: current_user.id})}, status: :ok
				else
					render json: {errors: ['Crypto not owned']}, status: :unprocessable_entity
				end
			end

			def index_transactions
				@transactions = Transaction.where(user_id: current_user.id)
				render json: {transactions: @transactions.map {|transaction| TransactionSerializer.new(transaction)} }, status: :ok
			end

			def update_watchlist
				@crypto = Crypto.find_by(gecko_id: watchlist_params[:gecko_id])
				if @crypto
					user_crypto = UserCrypto.find_or_create_by(user_id: current_user.id, crypto_id: @crypto.id) do |uc|
					  uc.on_watchlist = watchlist_params[:on_watchlist]
					  uc.quantity = 0 if uc.new_record?
					end
				  
					if user_crypto.save
						if user_crypto.new_record?
							render json: { messages: ['UserCrypto created successfully'] }, status: :ok
						else
							render json: { messages: ['UserCrypto updated successfully'] }, status: :ok
						end
					else
					  	render json: { errors: user_crypto.errors.full_messages }, status: :unprocessable_entity
					end
				else
					render json: { errors: ['Crypto not found'] }, status: :unprocessable_entity
				end
				
			end
			  
			  
			  

			private

			def user_params
				params.require(:user).permit(:email, :password, :password_confirmation, :phone_number, :balance)
			end

			def watchlist_params
				params.require(:watchlist).permit(:gecko_id, :on_watchlist)
			end

			

		end
	end
end

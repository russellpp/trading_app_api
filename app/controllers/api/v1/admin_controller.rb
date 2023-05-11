module Api 
	module V1
			class AdminController < ApplicationController
				before_action :authorized
				before_action :is_admin?

				def create_trader
					if trader_params[:password] != trader_params[:password_confirmation]
						render json: {errors: ['Passwords do not match!']}, status: :unprocessable_entity
					else 
						@user = User.create(trader_params)
						def_role = Role.find_by(name: "trader")
	
						
						if @user.valid?
							@user.user_roles.create(role: def_role)
							
							render json: {status: ["Trader account for #{@user.email} successfully created."]	}, status: :created
	
						else
							render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
						end
					end
				end

				def update_trader
					trader = User.find(params[:id])
					if trader_params[:password] == "" && trader_params[:password_confirmation] != trader_params[:password]
						render json: { errors: ["Password cannot be blank and should match"] }, status: :unprocessable_entity
					else
						if trader.update(trader_params)
						render json: { status: ["User updated!"] }, status: :ok
						else
						render json: { errors: trader.errors.full_messages }, status: :unprocessable_entity
						end				
					end
				end

				def show_trader
					trader = User.find_by(id: params[:id])
					if trader 
					  render json: {trader: UserSerializer.new(trader)}, status: :ok
					else
					  render json: {errors: 'User not found'}, status: :not_found
					end
				end
				  
				
				def index_traders
					traders = User.joins(:roles).where(roles: { name: 'trader'})
				  
					if traders.present?
					  render json: { traders: traders.map { |trader| UserSerializer.new(trader) } }, status: :ok
					else
					  render json: { errors: 'Traders not found' }, status: :not_found
					end
				end

				def pending_approval_traders
					traders = User.where(approved: nil)
					render json: { traders: traders.map { |trader| UserSerializer.new(trader) } }
				end

				def approve_trader
					@trader = User.find(params[:id])
					#approve thru verification
					@trader.approve!
					render json: {message: 'User approved for trading'}, status: :ok			
				end

				private

				def trader_params
					params.require(:trader).permit(:email, :password, :password_confirmation, :phone_number, :verified, :approved, :balance)
				end
			end
		
	end
end

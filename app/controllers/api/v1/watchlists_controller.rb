module Api
	module V1
		class WatchlistsController < ApplicationController
			before_action :authorized

			# def create
			# 	@watchlist = current_user.watchlists.build(watchlist_params)
				
			# 	if @watchlist.save
			# 	  crypto_ids = params[:watchlist][:crypto_ids]
			# 	  cryptos = Crypto.where(gecko_id: crypto_ids)
				
			# 	  cryptos.each do |crypto|
			# 		@watchlist.cryptos << crypto
			# 	  end
				  
			# 	  render json: {watchlist: WatchlistSerializer.new(@watchlist)}, status: :created
			# 	else
			# 	  render json: {errors: @watchlist.errors.full_messages}, status: :unprocessable_entity
			# 	end
			# end
			  
			  
			# def index
			# 	@watchlists = Watchlist.all
			# 	if @watchlists
			# 		render json: { watchlist: @watchlists.map { |list| WatchlistSerializer.new(list) } }, status: :ok
			# 	else
			# 		render json: { errors: 'Watchlists not found' }, status: :not_found
			# 	end
			# end

			# def show
			# 	@watchlist = Watchlist.find(params[:id])
			# 	if @watchlist
			# 		render json: {watchlist: WatchlistSerializer.new(@watchlist)}, status: :ok
			# 	else
			# 		render json: {errors: ['Watchlist not found']}, status: :not_found
			# 	end
			# end
            
			# def destroy
			# 	@watchlist = Watchlist.find(params[:id])
			# 	if @watchlist
			# 		@watchlist.destroy
			# 		render json: {messages: ['Watchlist deleted']}, status: :ok
			# 	else
			# 		render json: {messages: ['Watchlist not found']}, status: :not_found
			# 	end
			# end

			# def update
			# 	@watchlist = Watchlist.find(params[:id])
			# 	if @watchlist.update(watchlist_params)
			# 	  crypto_to_add = Crypto.where(id: watchlist_params[:added_crypto])
			  
			# 	  if crypto_to_add.present?
			# 		@watchlist.cryptos << crypto_to_add
			# 	  end
			  
			# 	  render json: { watchlist: WatchlistSerializer.new(@watchlist) }, status: :ok
			# 	else
			# 	  render json: { errors: @watchlist.errors.full_messages }, status: :unprocessable_entity
			# 	end
			# end
			  
			
			# def add_crypto
			# 	@watchlist = Watchlist.find(params[:watchlist_id])
			# 	@crypto = Crypto.find_by(gecko_id: params[:id])
			  
			# 	if @watchlist.cryptos.include?(@crypto)
			# 	  render json: { error: "Crypto already exists in watchlist" }, status: :unprocessable_entity
			# 	else
			# 	  @watchlist.cryptos << @crypto
			# 	  render json: { watchlist: WatchlistSerializer.new(@watchlist) }, status: :ok
			# 	end
			# end

			# private

			# def watchlist_params
			# 	params.require(:watchlist).permit(:name, crypto_ids: [])
				
			# end

			

		end
	end
end
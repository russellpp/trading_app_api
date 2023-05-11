module Api
    module V1
        class TransactionsController < ApplicationController
            before_action :authorized
            before_action :approved, only: [:create]
            before_action :is_admin?, only: [:index, :show]
            include Transaction::Handler

            def create 
                coin = Crypto.find_by(gecko_id: (transaction_params[:gecko_id]))
                if coin
                    total_value = transaction_params[:total_value].to_f
                    quantity = transaction_params[:quantity].to_f
                    user = current_user
                    ##service = TradingService.new
                    
                    status = case transaction_params[:transaction_type]
                    when 'buy'
                        Transaction::Handler.buy!(user, coin, quantity, total_value)
                    when 'sell'
                        Transaction::Handler.sell!(user, coin, quantity, total_value)
                    end

                    render json: status[:message], status: status[:status]
                else 
                    render json: {errors: ['Crypto not for trading']}, status: :unprocessable_entity
                end
            end

            def index
                @transactions = Transaction.all
                render json: {transactions: @transactions.map {|transaction| TransactionSerializer.new(transaction)} }, status: :ok
            end

            def show
                @transactions = Transaction.where(user_id: params[:id])
				render json: {transactions: @transactions.map {|transaction| TransactionSerializer.new(transaction)} }, status: :ok
            end

            private

            def transaction_params
                params.require(:transaction).permit(:transaction_type, :quantity, :total_value, :user_id, :gecko_id)
            end
        end
    end
end

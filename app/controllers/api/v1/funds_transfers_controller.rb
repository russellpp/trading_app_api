module Api
    module V1
        class FundsTransfersController < ApplicationController
            before_action :authorized
            before_action :approved

            def create 
                @user = current_user
                amount = funds_transfer_params[:amount]

                if amount.to_f > 0 
                    status = case funds_transfer_params[:transaction_type]
                    when 'withdraw'
                        @user.withdraw(amount.to_f)
                    when 'deposit'
                        @user.deposit(amount.to_f)
                    end
                    render json: status[:message], status: status[:status]
                else 
                    render json: {errors: ['invalid amount']}, status: :unprocessable_entity                        
                end

            end

            def index
                    @transfers = FundsTransfer.all
                    render json: {funds_transfers: @transfers.map {|funds_transfer| FundsTransferSerializer.new(funds_transfer)} }, status: :ok
            end

            def show
                    @transfer = FundsTransfer.find_by(id: params[:id])

                    if @transfer
                        render json: {funds_transfer: FundsTransferSerializer.new(@transfer)}, status: :ok
                    else
                        render json: {errors: ['Transfer not found']}, status: :not_found
                    end
            end

            private

            def funds_transfer_params
                    params.require(:funds_transfer).permit(:transaction_type, :amount)
            end
        end
    end
end

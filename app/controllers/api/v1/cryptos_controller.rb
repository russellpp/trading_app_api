module Api
    module V1
        class CryptosController < ApplicationController
            before_action :authorized

            def index
                @cryptos = Crypto.all
                render json: {cryptos: @cryptos.map {|crypto| CryptoSerializer.new(crypto)} }, status: :ok
            end

        end
    end
end

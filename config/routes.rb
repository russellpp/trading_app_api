Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      get 'coverage', to: redirect('/coverage/index.html')

      #admin
      scope '/admin' do
        post 'create_trader', to: 'admin#create_trader'
        patch 'update/:id', to: 'admin#update_trader'
        get 'show/:id', to: 'admin#show_trader'
        get 'index', to: 'admin#index_traders'
        get 'pending', to: 'admin#pending_approval_traders'
        put 'approve/:id', to: 'admin#approve_trader'
      end
  
      #users
      resources :users, only: [:create, :show, :update] do     
        collection do
          resources :funds_transfers, only: [:index, :show, :create]
          
          # resources :watchlists do
          #   put 'add_crypto/:id', to: 'watchlists#add_crypto'
          # end
          get 'coin/:id', to: 'users#show_owned_crypto'
          get 'coins', to: 'users#index_owned_cryptos'
          get 'transactions', to: 'users#index_transactions'    
          patch 'update_watchlist', to: 'users#update_watchlist'

        end
      end
      post 'register', to: 'users#create', as: 'register'
      
      #transactions (admin(permission only))
      resources :transactions, only: [:index, :show, :create]
      post 'trade', to: 'transactions#create'
      
      #cryptos
      resources :cryptos, only: [:index]
      
      #auth
      post 'verify', to: 'auth#confirm_verification'
      post 'login', to: 'auth#login', as: 'login'   
      post 'password_reset', to: 'auth#password_reset'
      post 'confirm_reset', to: 'auth#confirm_password_reset'
      post 'send_code', to: 'auth#send_code'
      
      
      
    end
  end
end

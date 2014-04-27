Mattforni::Application.routes.draw do
  # Setup root route
  root :to => 'application#splash'

  # Setup devise routes for users
  devise_for :users

  # Setup finance routes
  scope '/finance' do
    get '/last_trade', to: 'finance#last_trade'
    get '/sizing', to: 'finance#sizing'
    get '/stocks/update', to: 'finance#update_stocks'
  end
  namespace 'finance' do
    get '/stops/analyze', to: 'stops#analyze'
    resources :holdings
    resources :stops
  end
end


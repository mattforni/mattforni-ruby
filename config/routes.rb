Mattforni::Application.routes.draw do
  # Setup root route
  root :to => 'application#splash'

  # Setup devise routes for users
  devise_for :users

  # Setup finance routes
  scope '/finance' do
    get '/last_trade', to: 'finance#last_trade'
    get '/sizing', to: 'finance#sizing'
  end
  namespace 'finance' do
    get '/stocks/update_last_trade', to: 'stocks#update_last_trade'
    get '/stops/analyze', to: 'stops#analyze'
    resources :holdings, :stops
  end
end


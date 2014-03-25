Mattforni::Application.routes.draw do
  root :to => 'application#splash' 
  resource :user_session

  # Blog controllers
=begin TODO uncomment when properly setup
  namespace '/blog' do
    resources :posts
  end
=end

  # Finance controllers
  get '/finance/last_trade', to: 'finance#last_trade'
  namespace 'finance' do
    get '/sizing', to: 'sizing#index'
    get '/stops/analyze', to: 'stops#analyze'
    resources :stops
  end
end


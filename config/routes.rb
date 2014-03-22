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
  namespace 'finance' do
    get '/last_trade', to: 'ajax#last_trade'
    get '/sizing', to: 'sizing#index'
    get '/stops/analyze', to: 'stops#analyze'
    resources :stops
  end
end


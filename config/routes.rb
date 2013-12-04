Mattforni::Application.routes.draw do
  root :to => 'application#splash' 
  resource :user_session
  scope '/blog' do
    resources :posts
  end
  get '/finance', to: 'finance#index' 
  post '/finance/position_sizing', to: 'finance#position_sizing'
end


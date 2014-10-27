Mattforni::Application.routes.draw do
  # Setup root route
  root :to => 'application#splash'

  # Setup devise routes for users
  devise_for :users

  # Setup finance routes
  get '/finance', as: :finance, to: 'finance#index'
  scope '/finance' do
    get '/charts/:symbol/(:period)',
      as: :charts,
      defaults: {
        period: 'six_months'
      },
      to: 'finance#charts'
    get '/historical/:symbol/(:period)',
      as: :historical,
      defaults: {
        period: 'one_month'
      },
      to: 'finance#historical'
    get '/last_trade', to: 'finance#last_trade'
    get '/positions', to: 'finance#positions'
    get '/sizing', to: 'finance#sizing'
    get '/stocks/update', to: 'finance#update_stocks'
  end
  namespace 'finance' do
    get '/stops/analyze', to: 'stops#analyze'
    resources :holdings, except: :index
    resources :stops, except: :index
  end
end


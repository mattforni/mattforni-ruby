Mattforni::Application.routes.draw do
  # Setup root route
  root :to => 'application#splash'

  # Setup devise routes for users
  devise_for :users

  # Setup finance routes
  scope '/finance' do
    get '/', as: :finance, to: 'finance#index'
    get '/charts/:symbol/(:period)',
      as: :charts,
      defaults: {
        period: 'six_months'
      },
      to: 'finance#charts'
    get '/details/:symbol', as: :details, to: 'finance#details'
    get '/historical/:symbol/(:period)',
      as: :historical,
      defaults: {
        period: 'one_month'
      },
      to: 'finance#historical'
    get '/quote/:symbol', as: 'finance_quote', to: 'finance#quote'
    get '/sizing', as: 'finance_sizing', to: 'finance#sizing'
  end
  namespace 'finance' do
    resources :portfolios, only: [:create, :index, :new]
    resources :positions, only: [:edit, :update]
    resources :holdings, only: [:create, :destroy, :new]
    resources :stops, except: :index
  end
end


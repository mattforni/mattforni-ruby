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
    get '/historical/:symbol/(:period)',
      as: :historical,
      defaults: {
        period: 'one_month'
      },
      to: 'finance#historical'
    get '/last_trade', to: 'finance#last_trade'
    get '/portfolio', as: 'finance_portfolio', to: 'finance#portfolio'
    # TODO This is just a redirect now to portfolio, it should be removed later
    get '/positions', as: 'finance_positions', to: 'finance#positions'
    get '/sizing', as: 'finance_sizing', to: 'finance#sizing'
  end
  namespace 'finance' do
    resources :portfolios, only: [:new, :create]
    resources :holdings, except: :index
    resources :stops, except: :index
  end
end


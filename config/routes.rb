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
		get '/sizing', to: 'sizing#index'
		# TODO add back in once stops are enabled
		#resources :stops
		get '/quote', to: 'ajax#quote'
  end
end


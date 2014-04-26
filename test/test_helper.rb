ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factory_girl_rails'
require 'mocha'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end

class ActionController::TestCase < ActiveSupport::TestCase
  protected

  def login(user = users(:user))
    @controller.stubs(:authenticate_user!).returns(true)
    @controller.stubs(:current_user).returns(user)
  end
end


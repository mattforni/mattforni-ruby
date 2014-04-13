ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all
end

class ActionController::TestCase < ActiveSupport::TestCase
  include Devise::TestHelpers
  include Warden::Test::Helpers
end


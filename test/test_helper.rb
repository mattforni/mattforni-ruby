ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factory_girl_rails'
require 'validity'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Validity::ActiveRecord
end


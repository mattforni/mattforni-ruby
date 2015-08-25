# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'validity'

include Validity

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Include FactoryGirl methods
  config.include FactoryGirl::Syntax::Methods

  # Include Devise methods
  config.include Devise::TestHelpers, type: :controller
  config.extend DeviseController, type: :controller

  # Include ApplicationController messaging
  config.include ApplicationController::Messages, type: :controller

  config.infer_spec_type_from_file_location!

  # Configure Validity
  Validity.configure(Validity::TestUnit)
end

# TODO these aren't working, but revisit this idea
def validate_belongs_to(record, models)
  models.each do |model|
    it "belongs_to :#{model}" do
      record.belongs_to model, record.record.send(model)
    end
  end
end

def validate_delegation(record, delegations)
  delegations.each do |delegation|
    it "delegates :#{delegation[:field]} to :#{delegation[:to]}" do
      record.delegates delegation[:field], record.record.send(delegation[:to])
    end
  end
end

def validate_presence(record, fields)
  fields.each do |field|
    it "has :#{field} field" do
      record.field_presence field
    end
  end
end

def quote_response(attributes = {lastTrade: 10, symbol: 'FORN', name: 'Forni Co.'})
  attributes[:name] = 'Forni Co.' if attributes.class == Hash and !attributes.has_key?(:name)
  attributes[:symbol] = 'FORN' if attributes.class == Hash and !attributes.has_key?(:symbol)

  struct = OpenStruct.new()
  struct.name = attributes[:name]

  quote = Quote.new(struct)
  attributes.each_pair { |k, v| quote[k] = v } if quote.valid?

  response = {}
  response[attributes[:symbol]] = quote
  response
end


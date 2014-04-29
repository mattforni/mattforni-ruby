source 'http://rubygems.org'

ruby '1.9.3'

# Core gems
gem 'rails', '~> 4.0'
gem 'unicorn', '~> 4.8'

# Finance gems
gem 'yahoofinance', '~> 1.2'

# Rendering and markup gems
gem 'haml-rails', '~> 0.4'
# gem 'RedCloth', '>= 4.2.9'

# The JavaScript libraries
gem 'jquery-rails', '~> 3.1'
gem 'angularjs-rails', '~> 1.2'
gem 'chartjs-rails', '~> 0.1'

# Authentication
gem 'devise', '~> 3.2'

# Authorization
gem 'cancan', '~> 1.6'

gem 'acts-as-taggable-on', '>= 2.4.1'

# Gem groups
group :assets do
  gem 'coffee-rails', '~> 4.0'
  gem 'sass-rails', '~> 4.0'
  gem 'uglifier', '~> 1.3'
end

group :development, :test do
  gem 'sqlite3', '~> 1.3'
end

group :doc do
  gem 'sdoc', require: false
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

group :test do
  gem 'factory_girl_rails', '~> 4.4'
  gem 'rspec-rails', '~> 2.14'
  gem 'mocha', '~> 1.0'
end


source 'http://rubygems.org'

ruby '2.2.2'

# Core gems
gem 'rails', '~> 4.1'
gem 'puma', '~> 2'
gem 'rack-timeout', '~> 0.2'

# Finance gems
gem 'stocks', '~> 1.0'
# gem 'stocks', '~> 1.0', path: '~/Personal/gems'

# Rendering and markup gems
gem 'haml-rails', '~> 0.4'
gem 'nokogiri', '~> 1.6'
gem 'premailer-rails', '~> 1.8'
# gem 'RedCloth', '>= 4.2.9'

# The JavaScript libraries
gem 'angularjs-rails', '~> 1.2'
gem 'flot-rails', '~> 0.0'
gem 'gon', '~> 5.1'
gem 'highcharts-rails', '~> 4'
gem 'jquery-rails', '~> 4'
gem 'therubyracer', '~> 0'

# Authentication
gem 'devise', '~> 3.2'

# Authorization
gem 'cancan', '~> 1.6'

gem 'acts-as-taggable-on', '>= 2.4.1'

# Gem groups
group :assets do
  gem 'sass-rails', '~> 4.0', require: 'sass'
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
  gem 'rspec-rails', '~> 3'
  gem 'minitest', '~> 5.3'
  gem 'validity', '~> 1.0'
end


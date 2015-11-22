source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'compass-rails'
gem 'foundation-rails', '~> 5.5.1.0'
# Mongoid for database
gem 'mongoid', '~> 5.0.0'
gem 'sunspot_mongo'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
gem 'js-routes'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Use jquery for easier dynamic behaviour
gem 'angularjs-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# ERB replacement
gem 'haml'
# Simplify URLs
# gem 'friendly_id', '~> 5.1.0', require: false

# transferring data to the javascript
gem 'gon'

# Sprockts for compressing data
gem 'sprockets-rails', require: 'sprockets/railtie'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development



group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # a standalone Sunspot server
  gem 'sunspot_solr'
  # generate fake data
  gem 'forgery'

  # testing
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem "capybara-webkit"
  gem 'rspec-rails'
  gem 'mongoid-rspec', '3.0.0'
  gem 'database_cleaner'

  gem 'pry'
  gem 'pry-doc', '>= 0.6.0'
  gem 'method_source', '>= 0.8.2'
  gem 'pry-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '= 1.4.0'

  # the thin http server for development
  gem 'thin'
end

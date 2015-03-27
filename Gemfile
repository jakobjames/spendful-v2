source 'https://rubygems.org'
ruby "2.1.2"

gem 'rails', '3.2.6'
gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-rails'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'sass-rails',   '~> 3.2.3'
	gem 'compass-rails'
  gem 'bootstrap-sass', '~> 3.1.1'
  gem 'jquery-ui-rails'
end

gem 'haml-rails'
# gem 'coffee-filter'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0', :require => 'bcrypt'

group :development, :test do
  gem 'rspec', '~> 2.11.0'
  gem 'rspec-rails', '~> 2.11.0'
  gem 'capybara', '~> 1.1.2'
  gem 'capybara-webkit', '~> 0.12.1'
  gem 'capybara-email', :require => false

  gem 'faker'
  gem 'timecop'

  gem 'simplecov', :require => false
  gem 'simplecov-html', :require => false

  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rails'
  
  gem "letter_opener"
end

group :production do
	gem 'rails_12factor'
end

gem 'thin'

# hosting
gem 'heroku'

# error reporting
gem 'sentry-raven'

# https://github.com/seejohnrun/ice_cube
gem 'ice_cube'

gem 'money'
gem 'country_select'

# subscriptions
gem 'stripe'
gem 'stripe_event'

gem 'mail_view', :git => 'https://github.com/37signals/mail_view.git'

gem 'uuidtools'

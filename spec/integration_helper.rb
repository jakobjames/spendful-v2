require 'spec_helper'
require 'capybara/rspec'

Capybara.javascript_driver = :webkit

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

module Spendful
  module IntegrationHelpers
    def safe_find(*args)
      begin
        find(*args)
      rescue Capybara::ElementNotFound
        nil
      end
    end # def safe_find

    def sign_in(options = {})
      user = options.delete(:user)
      user ||= Spendful::Factories::Factory.create :user, options

      visit login_path
      fill_in 'Email', :with => user.email
      fill_in 'Password', :with => user.password
      click_button 'Continue'
      user
    end # def sign_in

  end
end

RSpec.configure do |config|
  config.include(Spendful::IntegrationHelpers, :type => :request)

  config.after(:each, :type => :request) do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

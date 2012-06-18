# primary place for setting ENV['COVERAGE'] is the rake tasks
if ENV['COVERAGE'] == 'on'
  require 'simplecov'
  SimpleCov.start 'rails'
end
require 'capybara/rails'
require "selenium/webdriver"
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
    # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Stop ActiveRecord from wrapping tests in transactions
  self.use_transactional_fixtures = false

 # Capybara.register_driver :chrome do |app|
 #   profile = Selenium::WebDriver::Chrome::Profile.new
 #   profile["download.default_directory"] = Rails.root.join("tmp/downloads")
 #   Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
 # end

 # Capybara.default_driver = Capybara.javascript_driver = :chrome
 # Capybara.default_driver = :webkit


  teardown do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
end

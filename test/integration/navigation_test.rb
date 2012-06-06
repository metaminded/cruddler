require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest

  test "visit index page" do
    visit '/houses'
  end

end


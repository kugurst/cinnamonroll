require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  test "should get landing" do
    get :landing
    assert_response :success
  end

  test "should get about_me" do
    get :about_me
    assert_response :success
  end

end

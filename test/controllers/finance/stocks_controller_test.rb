require 'test_helper'

class Finance::StocksControllerTest < ActionController::TestCase
  test "should get update_last_trade" do
    get :update_last_trade, {format: 'json', token: 'f0rnac0pia'}
    assert_response :success
  end
end


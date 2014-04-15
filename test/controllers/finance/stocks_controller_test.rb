require 'test_helper'

class Finance::StocksControllerTest < ActionController::TestCase
  test "should get update_last_trade" do
    get :update_last_trade
    assert_response :success
  end

end

require 'test_helper'

class Finance::StopsControllerTest < ActionController::TestCase
  def setup
    @user = create(:user)
    @stock = create(:stock)
    @position = create(:position,
      stock: @stock,
      user: @user
    )
    @stop = create(:stop,
      position: @position,
      user: @user
    )
    login(@user)
  end

  test 'get index functionality and template' do
    get :index
    assert_response :success
    assert_template :index
    assert_template layout: 'layouts/application'
    stops = assigns(:stops)
    assert_not_nil stops, 'Stops index set stops to nil'
    assert !stops.empty?, 'Stops index did not find any stops'
    assert_equal 1, stops.size, 'Stops index did not return a single stop'
  end
end


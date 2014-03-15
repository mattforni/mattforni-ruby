require 'test_helper'

class Finance::StopsControllerTest < ActionController::TestCase
  setup { @stop = stops(:default) }

  test 'get index functionality and template' do
    get :index
    assert_response :success, 'Stops index returned an error code'
    assert_template :index
    assert_template layout: 'layouts/application'
    stops = assigns(:stops)
    assert_not_nil stops, 'Stops index set stops to nil'
    assert !stops.empty?, 'Stops index did not find any stops'
    assert_equal 1, stops.size, 'Stops index did not return a single stop'
  end
end


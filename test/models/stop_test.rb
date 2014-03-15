require 'test_helper'

class StopTest < ActiveSupport::TestCase
  test 'attempt update functionality' do
    stop = stops(:default)
    symbol = stop.symbol
    assert_respond_to stop, :attempt_update, 'Stop cannot calculate stop price'

    # Test when stop symbol is invalid
    stop.symbol = 'Invalid'
    stop_price = stop.stop_price
    assert_nothing_raised { assert !stop.attempt_update, 'Stop was updated despite being invalid' }
    assert_equal stop_price, stop.stop_price, 'Stop price does not still equal previous price'

    # Test when stop price is nil
    stop.symbol = symbol
    stop.stop_price = nil
    assert_nil stop.stop_price, 'Stop has an associated stop price'
    assert_nothing_raised { assert stop.attempt_update, 'Stop was not updated despite nil stop price' }
    assert_not_nil stop.stop_price, 'Stop does not have an associated stop price'

    # Test when new stop is less than stop price
    stop.stop_price = BigDecimal::INFINITY
    assert_nothing_raised { assert !stop.attempt_update, 'Stop was updated despite infinite stop price' }
    assert_equal BigDecimal::INFINITY, stop.stop_price, 'Stop price still equals infinity'

    # Test when new stop is greater than stop price
    stop.stop_price = -1 
    assert_nothing_raised { assert stop.attempt_update, 'Stop was not updated despite negative stop price' }
    assert_not_equal -1, stop.stop_price, 'Stop still equals previous price'
  end

  test 'precentage presence validation' do
    stop = stops(:default)
    stop.percentage = nil
    assert !stop.valid?, 'Stop is considered valid'
    assert !stop.save, 'Stop saved without a percentage'
    assert stop.errors[:percentage].any?, 'Stop does not have an error on percentage'
  end

  test 'precentage under range validation' do
    stop = stops(:default)
    stop.percentage = 0 
    assert !stop.valid?, 'Stop is considered valid'
    assert !stop.save, 'Stop saved without a percentage equal to 0'
    assert stop.errors[:percentage].any?, 'Stop does not have an error on percentage'
  end

  test 'percentage over range validation' do
    stop = stops(:default)
    stop.percentage = 100
    assert !stop.valid?, 'Stop is considered valid'
    assert !stop.save, 'Stop saved without a percentage equal to 100'
    assert stop.errors[:percentage].any?, 'Stop does not have an error on percentage'
  end

  test 'stop_price presence validation' do
    stop = stops(:default)
    stop.stop_price = nil
    assert !stop.valid?, 'Stop is considered valid'
    assert !stop.save, 'Stop saved without a stop price'
    assert stop.errors[:stop_price].any?, 'Stop does not have an error on symbol'
  end

  test 'symbol presence validation' do
    stop = stops(:default)
    stop.symbol = nil
    assert !stop.valid?, 'Stop is considered valid'
    assert !stop.save, 'Stop saved without a symbol'
    assert stop.errors[:symbol].any?, 'Stop does not have an error on symbol'
  end

  test 'symbol uniqueness validation' do
    stop = Stop.new
    stops(:default).initialize_dup(stop)
    assert !stop.valid?, 'Stop is considered valid'
    assert !stop.save, 'Stop saved with a duplicate symbol'
    assert stop.errors[:symbol].any?, 'Stop does not have an error on symbol'
  end

  test 'symbol validity validation' do
    stop = stops(:default)
    stop.symbol = 'Invalid'
    assert !stop.save, 'Stop saved with an invalid symbol'
    assert stop.errors[:symbol].any?, 'Stop does not have an error on symbol'
  end
end


require 'test_helper'

class StopTest < ActiveSupport::TestCase
  setup { @stop = stops(:default) }

  test 'update last trade functionality' do
    symbol = @stop.symbol
    assert_respond_to @stop, :update_last_trade?, 'Stop cannot update last trade'

    # Test when stop symbol is invalid
    @stop.symbol = 'Invalid'
    last_trade = @stop.last_trade
    assert_nothing_raised { assert !@stop.update_last_trade?, 'Stop was updated despite being invalid' }
    assert_equal last_trade, @stop.last_trade, 'Last trade does not still equal previous value'

    # Test when last_trade is nil 
    @stop.symbol = symbol
    @stop.last_trade = nil
    assert_nothing_raised { assert @stop.update_last_trade?, 'Stop was not updated despite nil last trade' }
    assert_not_equal last_trade, @stop.last_trade , 'Last trade still equals previous value'

    # Test when last_trade has changed 
    @stop.last_trade = -1
    assert_nothing_raised { assert @stop.update_last_trade?, 'Stop was not updated despite negative last trade' }
    assert_not_equal -1, @stop.last_trade , 'Last trade still equals previous value'

    # Test when last_trade has not changed 
    last_trade = @stop.last_trade
    assert_nothing_raised { assert !@stop.update_last_trade?, 'Stop was updated despite still being equal to previous value' }
    assert_equal last_trade, @stop.last_trade , 'Last trade does not still equal previous value'
  end

  test 'update stop price functionality' do
    symbol = @stop.symbol
    last_trade = @stop.last_trade
    assert_respond_to @stop, :update_stop_price?, 'Stop cannot update stop price'

    # Test when last_trade is nil
    @stop.last_trade = nil
    stop_price = @stop.stop_price
    assert_nothing_raised { assert !@stop.update_stop_price?, 'Stop was updated despite being invalid' }
    assert_equal stop_price, @stop.stop_price, 'Stop price does not still equal previous value'

    # Test when stop_price is nil
    @stop.symbol = symbol
    @stop.last_trade = last_trade
    @stop.stop_price = nil
    assert_nil @stop.stop_price, 'Stop has an associated stop price'
    assert_nothing_raised { assert @stop.update_stop_price?, 'Stop was not updated despite nil stop price' }
    assert_not_nil @stop.stop_price, 'Stop does not have an associated stop price'

    # Test when new stop is less than stop_price
    @stop.stop_price = BigDecimal::INFINITY
    assert_nothing_raised { assert !@stop.update_stop_price?, 'Stop was updated despite infinite stop price' }
    assert_equal BigDecimal::INFINITY, @stop.stop_price, 'Stop price still equals infinity'

    # Test when new stop is greater than stop_price
    @stop.stop_price = -1 
    assert_nothing_raised { assert @stop.update_stop_price?, 'Stop was not updated despite negative stop price' }
    assert_not_equal -1, @stop.stop_price, 'Stop still equals previous value'

    # Test when stop_price has not changed 
    stop_price = @stop.stop_price
    assert_nothing_raised { assert !@stop.update_stop_price?, 'Stop was updated despite still being equal to previous value' }
    assert_equal stop_price, @stop.stop_price, 'Stop price does not still equal previous value'
  end

  test 'last_trade presence validation' do
    @stop.last_trade = nil
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved without a last trade'
    assert @stop.errors[:last_trade].any?, 'Stop does not have an error on last_trade'
  end

  test 'last_trade under range validation' do
    @stop.last_trade = 0 
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved with a last_trade equal to 0'
    assert @stop.errors[:last_trade].any?, 'Stop does not have an error on last_trade'
  end

  test 'precentage presence validation' do
    @stop.percentage = nil
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved without a percentage'
    assert @stop.errors[:percentage].any?, 'Stop does not have an error on percentage'
  end

  test 'percentage over range validation' do
    @stop.percentage = 100
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved with a percentage equal to 100'
    assert @stop.errors[:percentage].any?, 'Stop does not have an error on percentage'
  end

  test 'precentage under range validation' do
    @stop.percentage = 0 
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved with a percentage equal to 0'
    assert @stop.errors[:percentage].any?, 'Stop does not have an error on percentage'
  end

  test 'stop_price presence validation' do
    @stop.stop_price = nil
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved without a stop price'
    assert @stop.errors[:stop_price].any?, 'Stop does not have an error on stop_price'
  end

  test 'symbol presence validation' do
    @stop.symbol = nil
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved without a symbol'
    assert @stop.errors[:symbol].any?, 'Stop does not have an error on symbol'
  end

  test 'symbol uniqueness validation' do
    @stop = Stop.new
    stops(:default).initialize_dup(@stop)
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved with a duplicate symbol'
    assert @stop.errors[:symbol].any?, 'Stop does not have an error on symbol'
  end

  test 'symbol validity validation' do
    @stop.symbol = 'Invalid'
    assert !@stop.save, 'Stop saved with an invalid symbol'
    assert @stop.errors[:symbol].any?, 'Stop does not have an error on symbol'
  end
end


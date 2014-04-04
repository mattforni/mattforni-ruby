require 'stocks'
require 'test_helper'

include Stocks

class StopTest < ActiveSupport::TestCase
  setup { @stop = stops(:stop) }

  test 'price diff functionality' do
    assert_respond_to @stop, :price_diff, 'Stop cannot calculate price diff'

    # Test when last_trade less than stop_price
    @stop.last_trade = @stop.stop_price - 1
    assert_equal -1, @stop.price_diff, 'Price diff not calculated correctly when last_trade less than stop_price'

    # Test when last_trade equal to stop_price
    @stop.last_trade = @stop.stop_price
    assert_equal 0, @stop.price_diff, 'Price diff not calculated correctly when last_trade equal to stop_price'

    # Test when last_trade greater than stop_price
    @stop.last_trade = @stop.stop_price + 1
    assert_equal 1, @stop.price_diff, 'Price diff not calculated correctly when last_trade greater than stop_price'
  end

  test 'stopped out functionality' do
    assert_respond_to @stop, :stopped_out?, 'Stop cannot determine if stopped out'

    # Test when last_trade less than stop_price
    @stop.last_trade = @stop.stop_price - 1
    assert @stop.stopped_out?, 'Not stopped out despite last_trade being less than stop_price'

    # Test when last_trade equal to stop_price
    @stop.last_trade = @stop.stop_price
    assert @stop.stopped_out?, 'Not stopped out despite last_trade being equal to stop_price'

    # Test when last_trade greater than stop_price
    @stop.last_trade = @stop.stop_price + 1
    assert !@stop.stopped_out?, 'Stopped out despite last_trade being greater than stop_price'
  end

  test 'update last trade functionality' do
    symbol = @stop.symbol
    assert_respond_to @stop, :update_last_trade?, 'Stop cannot update last trade'

    # Test when stop symbol is invalid
    @stop.symbol = 'Invalid'
    last_trade = @stop.last_trade
    assert_raises (RetrievalError) { @stop.update_last_trade? }
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
    last_trade = @stop.last_trade

    assert_respond_to @stop, :update_stop_price?, 'Stop cannot update stop price'

    # Test when last_trade is nil
    @stop.last_trade = nil
    stop_price = @stop.stop_price
    assert_nil @stop.pinnacle_price, 'Stop has a pinnacle price'
    assert_nil @stop.pinnacle_date, 'Stop has a pinnacle date'
    assert_nothing_raised { assert @stop.update_stop_price?, 'Stop failed to update nil last trade' }
    assert_not_equal stop_price, @stop.stop_price, 'Stop price was not updated despite change'
    assert_not_nil @stop.pinnacle_price, 'Stop does note have a pinnacle price'
    assert_not_nil @stop.pinnacle_date, 'Stop does not have a pinnacle date'

    # Test when stop_price is nil
    @stop.last_trade= last_trade
    @stop.stop_price = nil
    @stop.pinnacle_price = nil
    @stop.pinnacle_date = nil
    assert_nothing_raised { assert @stop.update_stop_price?, 'Stop was not updated despite nil stop price' }
    assert_not_nil @stop.stop_price, 'Stop does not have an associated stop price'
    assert_not_nil @stop.pinnacle_price, 'Stop does note have a pinnacle price'
    assert_not_nil @stop.pinnacle_date, 'Stop does not have a pinnacle date'

    # Test when new stop is less than stop_price
    @stop.stop_price = BigDecimal::INFINITY
    assert_nothing_raised { assert !@stop.update_stop_price?, 'Stop was updated despite infinite stop price' }
    assert_equal BigDecimal::INFINITY, @stop.stop_price, 'Stop price still equals infinity'

    # Test when new stop is greater than stop_price
    @stop.stop_price = -1
    @stop.pinnacle_price = nil
    @stop.pinnacle_date = nil
    assert_nothing_raised { assert @stop.update_stop_price?, 'Stop was not updated despite negative stop price' }
    assert_not_equal -1, @stop.stop_price, 'Stop still equals previous value'
    assert_not_nil @stop.pinnacle_price, 'Stop does note have a pinnacle price'
    assert_not_nil @stop.pinnacle_date, 'Stop does not have a pinnacle date'

    # Test when stop_price has not changed
    stop_price = @stop.stop_price
    assert_nothing_raised { assert !@stop.update_stop_price?, 'Stop was updated despite still being equal to previous value' }
    assert_equal stop_price, @stop.stop_price, 'Stop price does not still equal previous value'
  end

  test 'validate last_trade presence' do
    @stop.last_trade = nil
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved without a last trade'
    assert @stop.errors[:last_trade].any?, 'Stop does not have an error on last_trade'
  end

  test 'validate last_trade under range' do
    @stop.last_trade = 0
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved with a last_trade equal to 0'
    assert @stop.errors[:last_trade].any?, 'Stop does not have an error on last_trade'
  end

  test 'validate precentage presence' do
    @stop.percentage = nil
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved without a percentage'
    assert @stop.errors[:percentage].any?, 'Stop does not have an error on percentage'
  end

  test 'validate percentage over range' do
    @stop.percentage = 100
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved with a percentage equal to 100'
    assert @stop.errors[:percentage].any?, 'Stop does not have an error on percentage'
  end

  test 'validate precentage under range' do
    @stop.percentage = 0
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved with a percentage equal to 0'
    assert @stop.errors[:percentage].any?, 'Stop does not have an error on percentage'
  end

  test 'validate stop_price presence' do
    @stop.stop_price = nil
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved without a stop price'
    assert @stop.errors[:stop_price].any?, 'Stop does not have an error on stop_price'
  end

  test 'validate symbol presence' do
    @stop.symbol = nil
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved without a symbol'
    assert @stop.errors[:symbol].any?, 'Stop does not have an error on symbol'
  end

  test 'validate symbol validity' do
    @stop.symbol = 'Invalid'
    assert !@stop.save, 'Stop saved with an invalid symbol'
    assert @stop.errors[:symbol].any?, 'Stop does not have an error on symbol'
  end
end


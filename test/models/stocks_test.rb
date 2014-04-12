require 'test_helper'

class StocksTest < ActiveSupport::TestCase
  setup { @stock = stocks(:stock) }

  test 'update last trade functionality' do
    symbol = @stock.symbol
    assert_respond_to @stock, :update_last_trade?, 'Stock cannot update last trade'

    # Test when stop symbol is invalid
    @stock.symbol = 'Invalid'
    last_trade = @stock.last_trade
    assert_raises (RetrievalError) { @stock.update_last_trade? }
    assert_equal last_trade, @stock.last_trade, 'Last trade does not still equal previous value'

    # Test when last_trade is nil 
    @stock.symbol = symbol
    @stock.last_trade = nil
    assert_nothing_raised { assert @stock.update_last_trade?, 'Stock was not updated despite nil last trade' }
    assert_not_equal last_trade, @stock.last_trade , 'Last trade still equals previous value'

    # Test when last_trade has changed 
    @stock.last_trade = -1
    assert_nothing_raised { assert @stock.update_last_trade?, 'Stock was not updated despite negative last trade' }
    assert_not_equal -1, @stock.last_trade , 'Last trade still equals previous value'

    # Test when last_trade has not changed 
    last_trade = @stock.last_trade
    assert_nothing_raised { assert !@stock.update_last_trade?, 'Stock was updated despite still being equal to previous value' }
    assert_equal last_trade, @stock.last_trade , 'Last trade does not still equal previous value'
  end
end


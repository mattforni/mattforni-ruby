require 'test_helper'

class StopTest < ActiveSupport::TestCase
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
  end

  test 'association of position' do
    validates(@stop).belongs_to :position, @position
  end

  test 'association of user' do
    validates(@stop).belongs_to :user, @user
  end

  test 'by user and symbol functionality' do
    assert_respond_to Stop, :by_user_and_symbol, 'Stop cannot be found by user and symbol'

    # Test when there is no stop with provided symbol
    assert Stop.by_user_and_symbol(@user, 'NoSymbol').empty?, 'Stop was found for an invalid symbol'

    user_id = @user.id
    # Test when there is no stop with provided user
    @user.id = -1
    assert Stop.by_user_and_symbol(@user, @stock.symbol).empty?, 'Stop was found for an invalid user'

    # Test when there is no stop with provided user and symbol
    assert Stop.by_user_and_symbol(@user, 'NoSymbol').empty?, 'Stop was found for an invalid user and symbol'

    # Test when there is a stop with provided user and symbol
    @user.id = user_id
    stops = Stop.by_user_and_symbol(@user, @stock.symbol)
    assert !stops.empty?, 'No stops were found for the default user and symbol'
    assert_equal 1, stops.size, 'There was not one stop for the default user and symbol'
    assert_equal @stop, stops.first, 'The found stop does not match the default stop'
  end

  test 'create! functionality when position does not exist' do
    @stop.destroy!
    @position.destroy!

    stop = create(:stop,
      position: @position,
      user: @user
    )
    stop.position = nil
    exception = assert_raise ActiveRecord::RecordInvalid do
      stop.create!
    end
  end

  test 'create! functionality when position does exist' do
    stop = create(:stop,
      position: @position,
      user: @user
    )
    stop.position = nil
    assert_nothing_raised { stop.create! }
  end

  test 'delegation of stock to position' do
    validates(@stop).delegates :stock, @stop.position
  end

  test 'delegation of last_trade to stock' do
    validates(@stop).delegates :last_trade, @stop.position.stock
  end

  test 'price diff functionality' do
    assert_respond_to @stop, :price_diff, 'Stop cannot calculate price diff'

    # Test when last_trade less than stop_price
    @stop.position.stock.last_trade = @stop.stop_price - 1
    assert_equal -1, @stop.price_diff, 'Price diff not calculated correctly when last_trade less than stop_price'

    # Test when last_trade equal to stop_price
    @stop.position.stock.last_trade = @stop.stop_price
    assert_equal 0, @stop.price_diff, 'Price diff not calculated correctly when last_trade equal to stop_price'

    # Test when last_trade greater than stop_price
    @stop.position.stock.last_trade = @stop.stop_price + 1
    assert_equal 1, @stop.price_diff, 'Price diff not calculated correctly when last_trade greater than stop_price'
  end

  test 'stopped out functionality' do
    assert_respond_to @stop, :stopped_out?, 'Stop cannot determine if stopped out'

    # Test when last_trade less than stop_price
    @stop.position.stock.last_trade = @stop.stop_price - 1
    assert @stop.stopped_out?, 'Not stopped out despite last_trade being less than stop_price'

    # Test when last_trade equal to stop_price
    @stop.position.stock.last_trade = @stop.stop_price
    assert @stop.stopped_out?, 'Not stopped out despite last_trade being equal to stop_price'

    # Test when last_trade greater than stop_price
    @stop.position.stock.last_trade = @stop.stop_price + 1
    assert !@stop.stopped_out?, 'Stopped out despite last_trade being greater than stop_price'
  end

  test 'update stop price functionality' do
    last_trade = @stop.last_trade

    assert_respond_to @stop, :update?, 'Stop cannot update stop price'

    # Test when last_trade is nil
    @stop.position.stock.last_trade = nil
    stop_price = @stop.stop_price
    assert_nothing_raised { assert @stop.update?, 'Stop failed to update nil last trade' }
    assert_not_equal stop_price, @stop.stop_price, 'Stop price was not updated despite change'
    assert_not_nil @stop.highest_price, 'Stop does not have a highest price'
    assert_not_nil @stop.highest_time, 'Stop does not have a highest time'

    # Test when stop_price is nil
    @stop.position.stock.last_trade = last_trade
    @stop.stop_price = nil
    @stop.highest_price = nil
    @stop.highest_time = nil
    assert_nothing_raised { assert @stop.update?, 'Stop was not updated despite nil stop price' }
    assert_not_nil @stop.stop_price, 'Stop does not have an associated stop price'
    assert_not_nil @stop.highest_price, 'Stop does not have a highest price'
    assert_not_nil @stop.highest_time, 'Stop does not have a highest time'

    # Test when new stop is less than stop_price
    @stop.stop_price = BigDecimal::INFINITY
    assert_nothing_raised { assert !@stop.update?, 'Stop was updated despite infinite stop price' }
    assert_equal BigDecimal::INFINITY, @stop.stop_price, 'Stop price still equals infinity'

    # Test when new stop is greater than stop_price
    @stop.stop_price = -1
    @stop.highest_price = nil
    @stop.highest_time = nil
    assert_nothing_raised { assert @stop.update?, 'Stop was not updated despite negative stop price' }
    assert_not_equal -1, @stop.stop_price, 'Stop still equals previous value'
    assert_not_nil @stop.highest_price, 'Stop does note have a highest price'
    assert_not_nil @stop.highest_time, 'Stop does not have a highest time'

    # Test when stop_price has not changed
    stop_price = @stop.stop_price
    assert_nothing_raised { assert !@stop.update?, 'Stop was updated despite still being equal to previous value' }
    assert_equal stop_price, @stop.stop_price, 'Stop price does not still equal previous value'
  end

  test 'validate highest_price presence' do
    validates(@stop).field_presence :highest_price
  end

  test 'validate highest_price under range' do
    @stop.highest_price = 0
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved with a highest price equal to 0'
    assert @stop.errors[:highest_price].any?, 'Stop does not have an error on highest_price'
  end

  test 'validate highest_time presence' do
    validates(@stop).field_presence :highest_time
  end

  test 'validate precentage presence' do
    validates(@stop).field_presence :percentage
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

  test 'validate position_id presence' do
    validates(@stop).field_presence :position_id
  end

  test 'validate stop_price presence' do
    validates(@stop).field_presence :stop_price
  end

  test 'validate stop_price under range' do
    @stop.stop_price = 0
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved with a stop price equal to 0'
    assert @stop.errors[:stop_price].any?, 'Stop does not have an error on stop_price'
  end

  test 'validate symbol presence' do
    validates(@stop).field_presence :symbol
  end

  test 'validate lowest_price presence' do
    validates(@stop).field_presence :lowest_price
  end

  test 'validate lowest_price under range' do
    @stop.lowest_price = 0
    assert !@stop.valid?, 'Stop is considered valid'
    assert !@stop.save, 'Stop saved with a lowest price equal to 0'
    assert @stop.errors[:lowest_price].any?, 'Stop does not have an error on lowest_price'
  end

  test 'validate lowest_time presence' do
    validates(@stop).field_presence :lowest_time
  end

  test 'validate user_id presence' do
    validates(@stop).field_presence :user_id
  end
end


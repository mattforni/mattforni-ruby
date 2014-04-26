require 'model_test'

class PositionsTest < ModelTest 
  setup { @position = positions(:position) }

  test 'association of holdings' do
    test_association_has_many @position, :holdings, Holding.where(position_id: @position.id)
  end

  test 'association of stock' do
    test_association_belongs_to @position, :stock, stocks(:stock)
  end

  test 'association of user' do
    test_association_belongs_to @position, :user, users(:user)
  end

  test 'by user and symbol functionality' do
    stock = stocks(:stock)
    user = users(:user)

    assert_respond_to Position, :by_user_and_symbol, 'Position cannot be found by user and symbol'

    # Test when there is no position with provided symbol
    assert_nil Position.by_user_and_symbol(user, 'NoSymbol'), 'Position was found for an invalid symbol'

    # Test when there is no position with provided user 
    user.id = -1
    assert_nil Position.by_user_and_symbol(user, stock.symbol), 'Position was found for an invalid user'

    # Test when there is no position with provided user and symbol
    assert_nil Position.by_user_and_symbol(user, 'NoSymbol'), 'Position was found for an invalid user and symbol'

    # Test when there is a stock with provided user and symbol
    user.id = 0
    found = Position.by_user_and_symbol(user, stock.symbol)
    assert_not_nil found, 'No position was found for the default user and symbol'
    assert_equal @position, found, 'The found position does not match the default position'
  end

  test 'delegation of last_trade to stock' do
    test_delegation(@position, @position.stock, :last_trade)
  end

  test 'update_weighted_avg! functionality' do
    assert_respond_to @position, :update_weighted_avg!, 'Position cannot update weighted avg'

    get_holding(@position).save!
    assert_equal 2, @position.holdings.size, 'Position does not have two holdings'

    # Test that other attributes raise an ArgumentError
    assert_raise ArgumentError do
      @position.update_weighted_avg!(:random)
    end

    # Test commission price is updated
    commission_price = @position.commission_price
    @position.update_weighted_avg!(:commission_price)
    assert_not_equal commission_price, @position.commission_price, 'Commission price was not updated'

    # Test purchase price is updated
    purchase_price = @position.purchase_price
    @position.update_weighted_avg!(:purchase_price)
    assert_not_equal purchase_price, @position.purchase_price, 'Purchase price was not updated'
  end

  test 'validate commission_price presence' do
    test_field_presence @position, :commission_price
  end

  test 'validate commission_price under range' do
    @position.commission_price = -0.0001
    assert !@position.valid?, 'Position is considered valid'
    assert !@position.save, 'Position saved with a commission price equal to 0'
    assert @position.errors[:commission_price].any?, 'Position does not have an error on commission_price'
  end

  test 'validate purchase_price presence' do
    test_field_presence @position, :purchase_price
  end

  test 'validate purchase_price under range' do
    @position.purchase_price = 0
    assert !@position.valid?, 'Position is considered valid'
    assert !@position.save, 'Position saved with a purchase price equal to 0'
    assert @position.errors[:purchase_price].any?, 'Position does not have an error on purchase_price'
  end

  test 'validate quantity presence' do
    test_field_presence @position, :quantity
  end

  test 'validate quantity under range' do
    @position.quantity = 0
    assert !@position.valid?, 'Position is considered valid'
    assert !@position.save, 'Position saved with a quantity equal to 0'
    assert @position.errors[:quantity].any?, 'Position does not have an error on quantity'
  end

  test 'validate stock_id presence' do
    test_field_presence @position, :stock_id
  end

  test 'validate symbol presence' do
    test_field_presence @position, :symbol
  end

  test 'validate user_id presence' do
    test_field_presence @position, :user_id
  end

  private

  def get_holding(position)
    holding = Holding.new({
      commission_price: 10,
      purchase_date: Date.today,
      purchase_price: 20,
      quantity: 200,
      symbol: 'AMZN',
      user_id: users(:user).id
    })
    holding.position = position
    holding
  end
end


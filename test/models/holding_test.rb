require 'model_test'

class HoldingsTest < ModelTest 
  setup { @holding = holdings(:holding) }

  test 'association of stock' do
    test_association_belongs_to @holding, :stock, stocks(:stock)
  end

  test 'association of user' do
    test_association_belongs_to @holding, :user, users(:user)
  end

  test 'create! functionality when symbol is nil or invalid' do
    holding = get_holding
    
    # Test when symbol is nil
    holding.symbol = nil
    assert_exception(holding, Stock)

    # Test when symbol is invalid
    holding.symbol = 'Invalid'
    assert_exception(holding, Stock)
  end

  test 'create! functionality when cp, pp or q is nil or invalid and Position does not exist' do
    user = get_user 
    holding = get_holding(user)

    # Test when commission_price is nil
    holding.commission_price = nil
    assert_exception(holding, Position)

    # Test when commission_price is negative
    holding.commission_price = -0.00001 
    assert_exception(holding, Position)

    # Test when purchase_price is nil
    holding.purchase_price = nil
    assert_exception(holding, Position)

    # Test when purchase_price is zero 
    holding.commission_price = 0 
    assert_exception(holding, Position)

    # Test when quantity is nil
    holding.quantity = nil
    assert_exception(holding, Position)

    # Test when quantity is zero 
    holding.quantity = 0 
    assert_exception(holding, Position)
  end

  test 'create! functionality when cp, pp or q is nil or invalid and Position does exist' do
    holding = get_holding
    stock = get_stock(holding)
    position = get_position(holding, stock)

    # Test when commission_price is nil
    holding.commission_price = nil
    assert_exception(holding, Holding, false)

    # Test when commission_price is negative
    holding.commission_price = -0.00001 
    assert_exception(holding, Holding, false)

    # Test when purchase_price is nil
    holding.purchase_price = nil
    assert_exception(holding, Holding, false)

    # Test when purchase_price is zero 
    holding.commission_price = 0 
    assert_exception(holding, Holding, false)

    # Test when quantity is nil
    holding.quantity = nil
    assert_exception(holding, Holding, false)

    # Test when quantity is zero 
    holding.quantity = 0 
    assert_exception(holding, Holding, false)
  end

  test 'create! functionality when purchase_date is nil' do
    holding = get_holding

    # Test when purchase_date is nil
    holding.purchase_date = nil
    assert_exception(holding, Holding)
  end

  test 'create! functionality when Stock and Position do not exist' do
    user = get_user 
    holding = get_holding(user)

    # There should not be a Stock or Position
    assert_nil Stock.by_symbol(holding.symbol), "Stock '#{holding.symbol}' already exists"
    assert_nil Position.by_user_and_symbol(user, holding.symbol), "Position '#{holding.symbol}' already exists"
    assert_nothing_raised { holding.create! }

    # There should be a Stock and Position
    assert_not_nil Stock.by_symbol(holding.symbol), "Stock '#{holding.symbol}' does not exists"
    assert_not_nil Position.by_user_and_symbol(user, holding.symbol), "Position '#{holding.symbol}' does not exist"

    assert_equal holding.commission_price, holding.position.commission_price, 'Commission prices are not equal'
    assert_equal holding.purchase_price, holding.position.purchase_price, 'Purchase prices are not equal'
    assert_equal holding.quantity, holding.position.quantity, 'Quantities are not equal'
  end

  test 'create! functionality when Stock and Position exist' do
    user = get_user 
    holding = get_holding(user)
    holding.symbol = holdings(:holding).symbol

    # There should be a Stock or Position
    assert_not_nil Stock.by_symbol(holding.symbol), "Stock '#{holding.symbol}' does not exist"
    assert_not_nil Position.by_user_and_symbol(user, holding.symbol), "Position '#{holding.symbol}' does not exist"
    assert_nothing_raised { holding.create! }

    assert_not_equal holding.commission_price, holding.position.commission_price, 'Commission prices are equal'
    assert_not_equal holding.purchase_price, holding.position.purchase_price, 'Purchase prices are equal'
    assert_not_equal holding.quantity, holding.position.quantity, 'Quantities are equal'
  end

  test 'delegation of stock to position' do
    test_delegation(@holding, @holding.position, :stock)
  end

  test 'validate commission_price presence' do
    test_field_presence @holding, :commission_price
  end

  test 'validate commission_price under range' do
    @holding.commission_price = -0.0001
    assert !@holding.valid?, 'Position is considered valid'
    assert !@holding.save, 'Position saved with a commission price equal to 0'
    assert @holding.errors[:commission_price].any?, 'Position does not have an error on commission_price'
  end

  test 'validate purchase_date presence' do
    test_field_presence @holding, :purchase_date
  end

  test 'validate purchase_price presence' do
    test_field_presence @holding, :purchase_price
  end

  test 'validate purchase_price under range' do
    @holding.purchase_price = 0
    assert !@holding.valid?, 'Position is considered valid'
    assert !@holding.save, 'Position saved with a purchase price equal to 0'
    assert @holding.errors[:purchase_price].any?, 'Position does not have an error on purchase_price'
  end

  test 'validate quantity presence' do
    test_field_presence @holding, :quantity
  end

  test 'validate quantity under range' do
    @holding.quantity = 0
    assert !@holding.valid?, 'Position is considered valid'
    assert !@holding.save, 'Position saved with a quantity equal to 0'
    assert @holding.errors[:quantity].any?, 'Position does not have an error on quantity'
  end

  test 'validate symbol presence' do
    test_field_presence @holding, :symbol
  end

  test 'validate user_id presence' do
    test_field_presence @holding, :user_id
  end

  private

  def assert_exception(holding, exception_on, run_assertions = true)
    exception = assert_raise ActiveRecord::RecordInvalid do
      holding.create!
    end
    assert_equal exception_on, exception.record.class, 'Exception was not on Stock model'
    if run_assertions
      assert_nil Stock.by_symbol(holding.symbol), "Stock '#{holding.symbol}' should not exist"
      assert_nil Position.by_user_and_symbol(holding.user, holding.symbol), "Position '#{holding.symbol}' does not exist"
    end
  end

  def get_holding(user = get_user)
    holding = Holding.new({
      commission_price: 10,
      purchase_date: Date.today,
      purchase_price: 20,
      quantity: 200,
      symbol: 'AMZN',
      user_id: user.id
    })
  end

  def get_position(holding, stock)
    position = Position.new({
      commission_price: holding.commission_price,
      purchase_price: holding.purchase_price,
      quantity: holding.quantity,
      symbol: holding.symbol
    })
    position.stock = stock
    position.user = holding.user
    assert position.save, "Position '#{holding.symbol}' could not be saved"
    assert_not_nil Position.by_user_and_symbol(holding.user, holding.symbol), "Position '#{holding.symbol}' does not exist"
    position
  end

  def get_stock(holding)
    stock = Stock.new({symbol: holding.symbol})
    stock.update?
    assert stock.save, "Stock '#{holding.symbol}' could not be saved"
    assert_not_nil Stock.by_symbol(holding.symbol), "Stock '#{holding.symbol}' does not exists"
    stock
  end

  def get_user
    user = users(:user)
    assert_not_nil user, "User '#{user.email}' does not exist"
    user
  end
end


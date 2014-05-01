require 'test_helper'

class HoldingsTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @stock = create(:stock)
    @position = create(:position,
      stock: @stock,
      user: @user
    )
    @holding = create(:holding,
      position: @position,
      user: @user
    )
  end

  test 'association of position' do
    validates(@holding).belongs_to :position, @position
  end

  test 'association of user' do
    validates(@holding).belongs_to :user, @user
  end

  test 'create! functionality when symbol is nil or invalid' do
    holding = build_holding(@position)

    # Test when symbol is nil
    holding.symbol = nil
    assert_exception(holding, Stock)

    # Test when symbol is invalid
    holding.symbol = 'Invalid'
    assert_exception(holding, Stock)
  end

  test 'create! functionality when cp, pp or q is nil or invalid and position does not exist' do
    holding = build_holding(@position)
    @position.destroy!
    @stock.destroy!
    holding.position = nil

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

  test 'create! functionality when cp, pp or q is nil or invalid and position does exist' do
    position = create_position(create_stock('AMZN'))
    holding = build_holding(position)

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
    position = create_position(create_stock('AMZN'))
    holding = build_holding(position)

    # Test when purchase_date is nil
    holding.purchase_date = nil
    assert_exception(holding, Holding, false)
  end

  test 'create! functionality when stock and position do not exist' do
    holding = build_holding(@position)
    @position.destroy!
    @stock.destroy!
    holding.position = nil

    # There should not be a Stock or Position
    assert_nil Stock.by_symbol(holding.symbol), "Stock '#{holding.symbol}' already exists"
    assert_nil Position.by_user_and_symbol(@user, holding.symbol), "Position '#{holding.symbol}' already exists"
    assert_nothing_raised { holding.create! }

    # There should be a Stock and Position
    assert_not_nil Stock.by_symbol(holding.symbol), "Stock '#{holding.symbol}' does not exists"
    assert_not_nil Position.by_user_and_symbol(@user, holding.symbol), "Position '#{holding.symbol}' does not exist"

    assert_equal holding.commission_price, holding.position.commission_price, 'Commission prices are not equal'
    assert_equal holding.purchase_price, holding.position.purchase_price, 'Purchase prices are not equal'
    assert_equal holding.quantity, holding.position.quantity, 'Quantities are not equal'
  end

  test 'create! functionality when stock and position exist' do
    holding = build_holding(@position)

    # There should be a Stock or Position
    assert_not_nil Stock.by_symbol(holding.symbol), "Stock '#{holding.symbol}' does not exist"
    assert_not_nil Position.by_user_and_symbol(@user, holding.symbol), "Position '#{holding.symbol}' does not exist"
    assert_nothing_raised { holding.create! }

    assert_not_equal holding.commission_price, holding.position.commission_price, 'Commission prices are equal'
    assert_not_equal holding.purchase_price, holding.position.purchase_price, 'Purchase prices are equal'
    assert_not_equal holding.quantity, holding.position.quantity, 'Quantities are equal'
  end

  test 'delegation of stock to position' do
    validates(@holding).delegates(:stock, @holding.position)
  end

  test 'validate commission_price presence' do
    validates(@holding).field_presence(:commission_price)
  end

  test 'validate commission_price under range' do
    @holding.commission_price = -0.0001
    assert !@holding.valid?, 'Position is considered valid'
    assert !@holding.save, 'Position saved with a commission price equal to 0'
    assert @holding.errors[:commission_price].any?, 'Position does not have an error on commission_price'
  end

  test 'validate purchase_date presence' do
    validates(@holding).field_presence(:purchase_date)
  end

  test 'validate purchase_price presence' do
    validates(@holding).field_presence(:purchase_price)
  end

  test 'validate purchase_price under range' do
    @holding.purchase_price = 0
    assert !@holding.valid?, 'Position is considered valid'
    assert !@holding.save, 'Position saved with a purchase price equal to 0'
    assert @holding.errors[:purchase_price].any?, 'Position does not have an error on purchase_price'
  end

  test 'validate quantity presence' do
    validates(@holding).field_presence(:quantity)
  end

  test 'validate quantity under range' do
    @holding.quantity = 0
    assert !@holding.valid?, 'Position is considered valid'
    assert !@holding.save, 'Position saved with a quantity equal to 0'
    assert @holding.errors[:quantity].any?, 'Position does not have an error on quantity'
  end

  test 'validate symbol presence' do
    validates(@holding).field_presence(:symbol)
  end

  test 'validate user_id presence' do
    validates(@holding).field_presence(:user_id)
  end

  private

  def assert_exception(holding, exception_on, run_assertions = true)
    exception = assert_raise ActiveRecord::RecordInvalid do
      holding.create!
    end
    assert_equal exception_on, exception.record.class, "Exception was not on #{exception_on} model"
    if run_assertions
      assert_nil Stock.by_symbol(holding.symbol), "Stock '#{holding.symbol}' should not exist"
      assert_nil Position.by_user_and_symbol(holding.user, holding.symbol), "Position '#{holding.symbol}' does not exist"
    end
  end

  def build_holding(position = nil)
    if position.nil?
      holding = build(:holding,
        commission_price: 10,
        purchase_price: 20,
        quantity: 200,
        user: @user
      )
    else
      holding = build(:holding,
        commission_price: 10,
        position: position,
        purchase_price: 20,
        quantity: 200,
        user: @user
      )
    end
  end

  def create_position(stock)
    position = create(:position,
      commission_price: 10,
      purchase_price: 20,
      quantity: 200,
      stock: stock,
      symbol: stock.symbol,
      user: @user
    )
    position
  end

  def create_stock(symbol)
    stock = create(:stock,
      symbol: symbol
    )
    stock
  end
end


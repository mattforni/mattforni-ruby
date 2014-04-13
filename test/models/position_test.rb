require 'model_test'

class PositionsTest < ModelTest 
  setup { @position = positions(:position) }

  test 'association of stock' do
    test_association_belongs_to @position, :stock, stocks(:stock)
  end

  test 'association of user' do
    test_association_belongs_to @position, :user, users(:user)
  end

  test 'delegation of last_trade to stock' do
    test_delegation(@position, @position.stock, :last_trade)
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
end


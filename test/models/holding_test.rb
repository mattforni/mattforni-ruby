require 'model_test'

class HoldingsTest < ModelTest 
  setup { @holding = holdings(:holding) }

  test 'association of stock' do
    test_association_belongs_to @holding, :stock, stocks(:stock)
  end

  test 'association of user' do
    test_association_belongs_to @holding, :user, users(:user)
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
end


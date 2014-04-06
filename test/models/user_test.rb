require 'model_test'

class UserTest < ModelTest
  setup { @user = users(:user) }

  test 'association of stops' do
    test_association_has_many @user, :stops, Stop.where(user_id: @user.id)
  end

  test 'validate email presence' do
    test_field_presence @user, :email
  end

  test 'validate email uniqueness' do
    test_field_uniqueness @user, :email
  end

  test 'validate encrypted_password presenece' do
    test_field_presence @user, :encrypted_password
  end
end


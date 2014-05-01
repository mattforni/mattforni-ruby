require 'test_helper'

class UserTest < ActiveSupport::TestCase
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
    @stop = create(:stop,
      position: @position,
      user: @user
    )
  end

  test 'association of holdings' do
    validates(@user).has_many :holdings, Holding.where(user_id: @user.id)
  end

  test 'association of stops' do
    validates(@user).has_many :stops, Stop.where(user_id: @user.id)
  end

  test 'validate email presence' do
    validates(@user).field_presence :email
  end

  test 'validate email uniqueness' do
    validates(@user).field_uniqueness :email
  end

  test 'validate encrypted_password presenece' do
    validates(@user).field_presence :encrypted_password
  end
end


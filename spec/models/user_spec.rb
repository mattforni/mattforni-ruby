require 'spec_helper'

describe User do
  before(:each) do
    allow(Stocks).to receive(:exists?).and_return(true)

    @user = Record.validates(create(:user))
    @holdings = [
      create(:holding, user: @user.record),
      create(:holding, user: @user.record)
    ]
    @portfolios = [
      create(:portfolio, user: @user.record),
      create(:portfolio, user: @user.record)
    ]
    @positions = [
      create(:position, user: @user.record),
      create(:position, user: @user.record)
    ]
    @stops = [
      create(:stop, user: @user.record),
      create(:stop, user: @user.record)
    ]
  end

  describe 'validations' do
    it 'has :email field' do
      @user.field_presence :email
    end

    it 'has :encrypted_password field' do
      @user.field_presence :encrypted_password
    end

    it 'is unique on :email field' do
      @user.field_uniqueness :email
    end

    it 'has many :holdings' do
      @user.has_many :holdings, @holdings
    end

    it 'has many :portfolios' do
      @user.has_many :portfolios, @portfolios
    end

    it 'has many :positions' do
      @user.has_many :positions, @positions
    end

    it 'has many :stops' do
      @user.has_many :stops, @stops
    end
  end
end


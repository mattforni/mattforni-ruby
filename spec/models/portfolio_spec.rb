require 'spec_helper'

include Validity

describe Portfolio do
  before(:each) do
    allow(Stocks).to receive(:exists?).and_return(true)

    @user = create(:user)
    @portfolio = Record.validates(create(:portfolio, user: @user))
    @positions = [
      create(:position, portfolio: @portfolio.record, user: @user),
      create(:position, portfolio: @portfolio.record, user: @user)
    ]
  end

  describe 'validations' do
    it 'has :name' do
      @portfolio.field_presence :name
    end

    it 'has :user_id' do
      @portfolio.field_presence :user_id
    end

    it 'is unique on :name' do
      @portfolio.field_uniqueness :name
    end

    it 'belongs to :user' do
      @portfolio.belongs_to :user, @user
    end

    it 'has many :positions' do
      @portfolio.has_many :positions, @positions
    end
  end
end


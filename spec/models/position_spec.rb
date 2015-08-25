require 'spec_helper'

describe Position do
  before(:all) do
    HIGHEST_PRICE = 15
    LOWEST_PRICE = 5
  end

  before(:each) do
    allow(Stocks).to receive(:exists?).and_return(true)

    @stock = create(:stock)
    @user = create(:user)
    @portfolio = create(:portfolio, {user: @user})
    @position = Record.validates(create(:position, {
      portfolio: @portfolio,
      stock: @stock
    }))
    @holdings = [
      create(:holding, {
        highest_price: HIGHEST_PRICE,
        lowest_price: LOWEST_PRICE + 1,
        position: @position.record
      }),
      create(:holding, {
        highest_price: HIGHEST_PRICE - 1,
        lowest_price: LOWEST_PRICE,
        position: @position.record
      }),
    ]
    @stops = [
      create(:stop, {position: @position.record}),
      create(:stop, {position: @position.record})
    ]
  end

  describe 'validations' do
    it 'has :commission_price field' do
      @position.field_presence :commission_price
    end

    it 'has :portfolio_id field' do
      @position.field_presence :portfolio_id
    end

    it 'has :purchase_price field' do
      @position.field_presence :purchase_price
    end

    it 'has :quantity field' do
      @position.field_presence :quantity
    end

    it 'has :stock_id field' do
      @position.field_presence :stock_id
    end

    it 'has :symbol field' do
      @position.field_presence :symbol
    end

    it 'has :user_id field' do
      @position.field_presence :user_id
    end
  end

  describe 'associations' do
    it 'belongs to portfolio' do
      @position.belongs_to :portfolio, @portfolio
    end

    it 'belongs to stock' do
      @position.belongs_to :stock, @stock
    end

    it 'belongs to user' do
      @position.belongs_to :user, @user
    end

    it 'has many holdings' do
      @position.has_many :holdings, @holdings
    end

    it 'has many stops' do
      @position.has_many :stops, @stops
    end
  end

  describe 'delegation' do
    it 'delegates :last_trade to stock' do
      @position.delegates :last_trade, @stock
    end
  end

  describe '#destroy!' do
    it 'should destroy dependent holdings and stops' do
      # Act
      @position.record.destroy!

      # Assert
      expect(@position.record.holdings).to be_empty
      expect(@position.record.stops).to be_empty
    end
  end

  describe '#highest_price' do
    context 'when there are no holdings' do
      it 'should return nil' do
        @holdings.each { |h| h.destroy! }

        expect(@position.record.highest_price).to be_nil
      end
    end

    context 'when there are holdings with different values' do
      it 'should return the highest value' do
        expect(@position.record.highest_price).to eq(HIGHEST_PRICE)
      end
    end
  end

  describe '#lowest_price' do
    context 'when there are no holdings' do
      it 'should return nil' do
        @holdings.each { |h| h.destroy! }

        expect(@position.record.lowest_price).to be_nil
      end
    end

    context 'when there are holdings with different values' do
      it 'should return the lowest value' do
        expect(@position.record.lowest_price).to eq(LOWEST_PRICE)
      end
    end
  end

  describe '#update!' do
    context 'when :total_quantity is equal to zero' do
      it 'should call #destroy! on itself and cascade deletion to stops' do
        @holdings.each { |h| h.destroy! }

        expect(@position.record.destroyed?).to be_truthy
        @stops.each do |s|
          expect { s.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end


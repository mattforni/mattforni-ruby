require 'spec_helper'

describe Stock do
  before(:each) do
    allow(Stocks).to receive(:exists?).and_return(true)

    @stock = Record.validates(create(:stock, {
      highest_price: 10,
      highest_time: Time.now.utc - 5.minutes,
      lowest_price: 10,
      lowest_time: Time.now.utc - 5.minutes
    }))
    @positions = [
      create(:position, stock: @stock.record),
      create(:position, stock: @stock.record)
    ]
    @holdings = [
      create(:holding, position: @positions[0]),
      create(:holding, position: @positions[0]),
      create(:holding, position: @positions[1]),
      create(:holding, position: @positions[1]),
    ]
  end

  describe 'validations' do
    it 'has :highest_price field' do
      @stock.field_presence :highest_price
    end

    it 'has :highest_time field' do
      @stock.field_presence :highest_time
    end

    it 'has :last_trade field' do
      @stock.field_presence :last_trade
    end

    it 'has :lowest_price field' do
      @stock.field_presence :lowest_price
    end

    it 'has :lowest_time field' do
      @stock.field_presence :lowest_time
    end

    it 'has :symbol field' do
      @stock.field_presence :symbol
    end

    it 'is unique on :symbol field' do
      @stock.field_uniqueness :symbol
    end

    it 'validates the symbol exists' do
      allow(Stocks).to receive(:exists?).and_return(false)

      expect { create(:stock) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'associations' do
    it 'has many holdings' do
      @stock.has_many :holdings, @holdings
    end

    it 'has many positions' do
      @stock.has_many :positions, @positions
    end
  end

  describe '::by_symbol' do
    context 'when stock does *not* exist' do
      it 'returns nil' do
        # Assert
        expect(Stock.by_symbol('Invalid')).to be_nil
      end
    end

    context 'when stock does exist' do
      it 'returns nil' do
        # Act
        stock = Stock.by_symbol @stock.record.symbol

        # Assert
        expect(stock).to_not be_nil
        expect(stock).to eq(@stock.record)
      end
    end
  end

  describe '#update!' do
    context 'when :last_trade has not changed' do
      it 'should not does not save' do
        # Arrange
        updated_at = @stock.record.updated_at
        allow(Quote).to receive(:get).and_return(mock_quote)

        # Act
        @stock.record.update!

        # Assert
        expect(@stock.record.updated_at).to eq(updated_at)
      end
    end

    context 'when :last_trade has changed' do
      it 'should update :last_trade' do
        # Arrange
        last_trade = 5
        allow(Quote).to receive(:get).and_return(mock_quote(last_trade))

        # Act
        @stock.record.update!

        # Assert
        expect(@stock.record.last_trade).to eq(last_trade)
      end
    end

    context 'when :last_trade is lower than :lowest_price' do
      it 'should update :lowest_price and :lowest_time' do
        # Arrange
        last_trade = @stock.record.last_trade - 1
        lowest_time = @stock.record.lowest_time
        allow(Quote).to receive(:get).and_return(mock_quote(last_trade))

        # Act
        @stock.record.update!

        # Assert
        expect(@stock.record.lowest_price).to eq(last_trade)
        expect(@stock.record.lowest_time).to_not eq(lowest_time)
      end
    end

    context 'when :last_trade is higher than :highest_price' do
      it 'should update :highest_price and :highest_time' do
        # Arrange
        last_trade = @stock.record.last_trade + 1
        highest_time = @stock.record.highest_time
        allow(Quote).to receive(:get).and_return(mock_quote(last_trade))

        # Act
        @stock.record.update!

        # Assert
        expect(@stock.record.highest_price).to eq(last_trade)
        expect(@stock.record.highest_time).to_not eq(highest_time)
      end
    end
  end 

  private

  def mock_quote(last_trade = 10)
    quote_response({symbol: @stock.record.symbol, lastTrade: last_trade})
  end
end


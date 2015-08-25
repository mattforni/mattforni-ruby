require 'spec_helper'

describe Position do
  BELONGS_TO = [
    :portfolio,
    :stock,
    :user
  ]

  HAS_MANY = [
    :holdings,
    :stops
  ]

  PRESENCE = [
    :commission_price,
    :portfolio_id,
    :purchase_price,
    :quantity,
    :stock_id,
    :symbol,
    :user_id
  ]

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

  describe 'associations' do
    BELONGS_TO.each do |belongs_to|
      it "belongs_to :#{belongs_to}" do
        @position.belongs_to belongs_to, @position.record.send(belongs_to)
      end
    end

    HAS_MANY.each do |has_many|
      it "has_many :#{has_many}" do
        @position.has_many has_many, @position.record.send(has_many)
      end
    end
  end

  describe 'delegation' do
    it 'delegates :last_trade to stock' do
      @position.delegates :last_trade, @stock
    end
  end

  describe 'validations' do
    PRESENCE.each do |field|
      it "has :#{field} field" do
        @position.field_presence field
      end
    end
  end

  describe '::by_user_and_symbol' do
    context 'when :position does not exist' do
      it 'returns nil' do
        # Assert
        expect(Position.by_user_and_symbol(@user, 'Invalid')).to be_nil
      end
    end

    context 'when :position does not exist for given :user' do
      it 'return nil' do
        # Arrange
        @user.id = -1

        # Assert
        expect(Position.by_user_and_symbol(@user, @stock.symbol)).to be_nil
      end
    end

    context 'when :position exists for :user and :symbol' do
      it 'returns the :position' do
        # Act
        position = Position.by_user_and_symbol(@user, @stock.symbol)

        # Assert
        expect(position).to_not be_nil
        expect(position).to eq(@position.record)
      end
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


require 'spec_helper'

# TODO This is now the premiere spec for validity!
describe Holding do
  BELONGS_TO = [
    :position,
    :user
  ]

  DELEGATION = [
    {field: :portfolio, to: :position},
    {field: :stock, to: :position},
    {field: :last_trade, to: :stock}
  ]

  PRESENCE = [
    :commission_price,
    :position_id,
    :purchase_date,
    :purchase_price,
    :quantity,
    :symbol,
    :user_id
  ]

  before(:each) do
    allow(Stocks).to receive(:exists?).and_return(true)

    @stock = create(:stock)
    @user = create(:user)
    @portfolio = create(:portfolio, user: @user)
    @position = create(:position, portfolio: @portfolio, user: @user, stock: @stock)
    @holding = Record.validates(create(:holding, position: @position))
  end

  describe 'associations' do
    BELONGS_TO.each do |belongs_to|
      it "belongs_to :#{belongs_to}" do
        @holding.belongs_to belongs_to, @holding.record.send(belongs_to)
      end
    end
  end

  describe 'delegation' do
    DELEGATION.each do |delegation|
      it "delegates :#{delegation[:field]} to :#{delegation[:to]}" do
        @holding.delegates delegation[:field], @holding.record.send(delegation[:to])
      end
    end
  end

  describe 'validations' do
    PRESENCE.each do |field|
      it "has :#{field} field" do
        @holding.field_presence field
      end
    end
  end

  describe '#destroy!' do
    context 'when is *not* the last holding' do
      it 'should *not* destroy the position and portfolio' do
        # Arrange
        create(:holding, position: @position)

        # Act
        @holding.record.destroy!

        # Assert
        expect(@holding.record.position.destroyed?).to be_falsey
        expect(@holding.record.portfolio.destroyed?).to be_falsey
      end
    end

    context 'when is the last holding for a position but not a portfolio' do
      it 'should destroy the position but *not* the portfolio' do
        # Arrange
        create(:holding, position: create(:position, portfolio: @portfolio, user: @user))

        # Act
        @holding.record.destroy!

        # Assert
        expect(@holding.record.position.destroyed?).to be_truthy
        expect(@holding.record.portfolio.destroyed?).to be_falsey
      end
    end

    context 'when is the last holding' do
      it 'should destroy the position and portfolio' do
        # Act
        @holding.record.destroy!

        # Assert
        expect(@holding.record.position.destroyed?).to be_truthy
        expect(@holding.record.portfolio.destroyed?).to be_truthy
      end
    end
  end
end


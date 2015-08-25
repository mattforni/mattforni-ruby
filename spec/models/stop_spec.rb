require 'spec_helper'

describe Stop do
  BELONGS_TO = [
    :position,
    :user
  ]

  DELEGATION = [
    {field: :stock, to: :position},
    {field: :last_trade, to: :stock}
  ]

  PRESENCE = [
    :highest_price,
    :highest_time,
    :lowest_price,
    :lowest_time,
    :percentage,
    :position_id,
    :user_id
  ]

  before(:each) do
    allow(Stocks).to receive(:exists?).and_return(true)

    @stock = create(:stock)
    @user = create(:user)
    @position = create(:position, {stock: @stock, user: @user})
    @stop = Record.validates(create(:stop, {position: @position}))
  end

  describe 'validations' do
    PRESENCE.each do |field|
      it "has :#{field} field" do
        @stop.field_presence field
      end
    end
  end

  describe 'associations' do
    BELONGS_TO.each do |belongs_to|
      it "belongs_to :#{belongs_to}" do
        @stop.belongs_to belongs_to, @stop.record.send(belongs_to)
      end
    end
  end

  describe 'delegation' do
    DELEGATION.each do |delegation|
      it "delegates :#{delegation[:field]} to :#{delegation[:to]}" do
        @stop.delegates delegation[:field], @stop.record.send(delegation[:to])
      end
    end
  end

  describe '#create!' do
    context 'when position does not exist' do
      it 'should raise a RecordInvalid error' do
        @position.destroy!

        expect {
          Stop.new({symbol: @stock.symbol, user: @user}).create!
        }.to raise_error(ActiveRecord::RecordInvalid, /could not be found/)
      end
    end

    context 'when :percentage is nil' do
      it 'should raise a RecordInvalid error' do
        expect {
          Stop.new({symbol: @stock.symbol, user: @user}).create!
        }.to raise_error(ActiveRecord::RecordInvalid, /cannot be nil/)
      end
    end

    context 'when position exists and :percentage is not nil' do
      it 'should create a new stop' do
        @stop = build(:stop, {position: @position})
        @stop.create!

        expect(@stop.id).to_not be_nil
      end
    end
  end

  describe '#stopped_out?' do
    context 'when :last_trade is less than or equal to :stop_price' do
      it 'should be truthy' do
        @stock.last_trade = @stop.record.stop_price
        @stock.save!

        expect(@stop.record.stopped_out?).to be_truthy
      end
    end

    context 'when :last_trade is greater than :stop_price' do
      it 'should be falsey' do
        @stock.last_trade = @stop.record.stop_price + 1
        @stock.save!

        expect(@stop.record.stopped_out?).to be_falsey
      end
    end
  end

  describe '#update?' do
    context 'when nothing has changed' do
      it 'should be falsey' do
        @stop = build(:stop, {position: @position})
        expect(@stop.update?).to be_falsey
      end
    end

    context 'when :stop_price has gone up' do
      it 'should updated :stop_price and be truthy' do
        @stop = build(:stop, {position: @position})
        stop_price = @stop.stop_price 
        @stock.last_trade += 1
        @stock.save!

        expect(@stop.update?).to be_truthy
        expect(@stop.stop_price).to_not be(stop_price)
      end
    end

    context 'when :last_trade is lower than :lowest_price' do
      it 'should update :lowest_price and :lowest_time and be truthy' do
        @stop = build(:stop, {position: @position})
        lowest_time = @stop.lowest_time
        @stock.last_trade = @stop.lowest_price - 1
        @stock.save!

        expect(@stop.update?).to be_truthy
        expect(@stop.lowest_price).to eq(@stock.last_trade)
        expect(@stop.lowest_time).to_not eq(lowest_time)
      end
    end

    context 'when :last_trade is higher than :highest_price' do
      it 'should update :highest_price and :highest_time and be truthy' do
        @stop = build(:stop, {position: @position})
        highest_time = @stop.highest_time
        @stock.last_trade = @stop.highest_price + 1
        @stock.save!

        expect(@stop.update?).to be_truthy
        expect(@stop.highest_price).to eq(@stock.last_trade)
        expect(@stop.highest_time).to_not eq(highest_time)
      end
    end
  end

  describe '#update_stop_price?' do
    context 'when :percentage has not changed' do
      it 'should be falsey' do
        expect(@stop.record.update_stop_price?).to be_falsey
      end
    end

    context 'when :percentage has changed' do
      it 'should update :percentage and :stop_price and be truthy' do
        params = {
          percentage: @stop.record.percentage + 1,
          stop_price: @stop.record.stop_price
        }

        expect(@stop.record.update_stop_price?(params)).to be_truthy
        expect(@stop.record.percentage).to eq(params[:percentage])
        expect(@stop.record.stop_price).to_not eq(params[:stop_price])
      end
    end

    context 'when :stop_price has changed' do
      it 'should update :stop_price and be truthy' do
        params = {
          percentage: @stop.record.percentage,
          stop_price: @stop.record.stop_price - 1
        }

        expect(@stop.record.update_stop_price?(params)).to be_truthy
        expect(@stop.record.percentage).to eq(params[:percentage])
        expect(@stop.record.stop_price).to eq(params[:stop_price])
      end
    end
  end
end


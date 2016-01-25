require 'spec_helper'

describe Alert do
  validates = {
    presence: [
      :active,
      :stock_id,
      :user_id
    ]
  }

  before(:each) do
    allow(Stocks).to receive(:exists?).and_return(true)

    @alert = Record.validates(create :alert)
  end

  describe 'validates' do
    validates.each_pair do |type, fields|
      fields.each do |field|
        it "#{type} of :#{field}" do
          @alert.send "field_#{type}", field
        end
      end
    end

    context 'when :greater_than is <= 0' do
      it 'raises an ActiveRecord::RecordInvalid' do
        @alert = build :alert
        @alert.greater_than = 0
        @alert.less_than = nil
        expect { @alert.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context 'when :less_than is <= 0' do
      it 'raises an ActiveRecord::RecordInvalid' do
        @alert = build :alert
        @alert.greater_than = nil
        @alert.less_than = 0
        expect { @alert.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    describe Ranges::AlertValidator do
      context 'when both :greater_than and :less_than are nil' do
        it 'raises an ArgumentError' do
          @alert = build :alert
          @alert.greater_than = nil
          @alert.less_than = nil
          expect { @alert.save! }.to raise_error ArgumentError
        end
      end

      context 'when :greater_than >= :less_than' do
        it 'raises an ArgumentError' do
          @alert = build :alert
          @alert.greater_than = @alert.less_than
          expect { @alert.save! }.to raise_error ArgumentError
        end
      end
    end
  end

  describe '#trigger?' do
    context 'when type is :greater_than' do
      context 'when :last_trade >= :greater_than' do
        it 'returns false' do
          # Arrange
          @alert.record.less_than = nil
          allow_any_instance_of(Stock).to receive(:last_trade).and_return(@alert.record.greater_than)

          # Act / Assert
          expect(@alert.record.trigger?).to be_falsey
        end
      end

      context 'when :last_trade < :greater_than' do
        it 'returns true' do
          # Arrange
          @alert.record.less_than = nil
          allow_any_instance_of(Stock).to receive(:last_trade).and_return(@alert.record.greater_than - 0.001)

          # Act / Assert
          expect(@alert.record.trigger?).to be_truthy
        end
      end
    end

    context 'when type is :less_than' do
      context 'when :last_trade <= :less_than' do
        it 'returns false' do
          # Arrange
          @alert.record.greater_than = nil
          allow_any_instance_of(Stock).to receive(:last_trade).and_return(@alert.record.less_than)

          # Act / Assert
          expect(@alert.record.trigger?).to be_falsey
        end
      end

      context 'when :last_trade > :less_than' do
        it 'returns true' do
          # Arrange
          @alert.record.greater_than = nil
          allow_any_instance_of(Stock).to receive(:last_trade).and_return(@alert.record.less_than + 0.001)

          # Act / Assert
          expect(@alert.record.trigger?).to be_truthy
        end
      end
    end

    context 'when type is :range' do
      context 'when :greater_than <= :last_trade and :last_trade <= :less_than' do
        it 'returns false' do
          # Arrange
          allow_any_instance_of(Stock).to receive(:last_trade).and_return(@alert.record.greater_than)

          # Act / Assert
          expect(@alert.record.trigger?).to be_falsey
        end
      end

      context 'when :last_trade < :greater_than' do
        it 'returns true' do
          # Arrange
          allow_any_instance_of(Stock).to receive(:last_trade).and_return(@alert.record.greater_than - 0.001)

          # Act / Assert
          expect(@alert.record.trigger?).to be_truthy
        end
      end

      context 'when :last_trade > :less_than' do
        it 'returns true' do
          # Arrange
          @alert.record.greater_than = nil
          allow_any_instance_of(Stock).to receive(:last_trade).and_return(@alert.record.less_than + 0.001)

          # Act / Assert
          expect(@alert.record.trigger?).to be_truthy
        end
      end
    end
  end

  describe '#type' do
    context 'when both :greater_than and :less_than are populated' do
      it 'has type of :range' do
        expect(@alert.record.type).to eq(Alert::TYPE[:range])
      end
    end

    context 'when :greater_than is nil' do
      it 'has type of :less_than' do
        @alert.record.greater_than = nil
        expect(@alert.record.type).to eq(Alert::TYPE[:less_than])
      end
    end

    context 'when :less_than is nil' do
      it 'has type of :greater_than' do
        @alert.record.less_than = nil
        expect(@alert.record.type).to eq(Alert::TYPE[:greater_than])
      end
    end
  end
end


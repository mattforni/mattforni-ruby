require 'spec_helper'

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
    it 'has :name field' do
      @portfolio.field_presence :name
    end

    it 'has :user_id field' do
      @portfolio.field_presence :user_id
    end

    it 'is unique on :name field' do
      @portfolio.field_uniqueness :name
    end
  end

  describe 'associations' do
    it 'belongs to :user' do
      @portfolio.belongs_to :user, @user
    end

    it 'has many :positions' do
      @portfolio.has_many :positions, @positions
    end
  end

  describe '::by_user_and_id' do
    context 'when user not provided' do
      it 'should raise an ArugmentError' do
        expect { Portfolio.by_user_and_id }.to raise_error(ArgumentError)
      end
    end

    context 'when portfolio with provided id does not exist' do
      it 'should raise a RecordNotFound error' do
        expect { Portfolio.by_user_and_id(@user, -1) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'should return the specified portfolio' do
      portfolio = Portfolio.by_user_and_id(@user, @portfolio.record.id)
      expect(portfolio).to_not be_nil
      expect(portfolio.name).to eq(@portfolio.record.name)
      expect(portfolio.user).to eq(@user)
    end
  end

  describe '::by_user_and_name' do
    context 'when user not provided' do
      it 'should raise an ArugmentError' do
        expect { Portfolio.by_user_and_name }.to raise_error(ArgumentError)
      end
    end

    context 'when portfolio with provided name does not exist' do
      it 'should raise a RecordNotFound error' do
        expect { Portfolio.by_user_and_name(@user, 'DNE') }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'should return the specified portfolio' do
      portfolio = Portfolio.by_user_and_name(@user, @portfolio.record.name)
      expect(portfolio).to_not be_nil
      expect(portfolio.name).to eq(@portfolio.record.name)
      expect(portfolio.user).to eq(@user)
    end
  end

  describe '::default' do
    context 'when user not provided' do
      it 'should raise an ArugmentError' do
        expect { Portfolio.default }.to raise_error(ArgumentError)
      end
    end

    context 'when default portfolio does not exist' do
      it 'should raise a RuntimeError' do
        @portfolio.record.destroy!

        expect { Portfolio.default(@user) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'should return the default portfolio' do
      portfolio = Portfolio.default(@user)
      expect(portfolio).to_not be_nil
      expect(portfolio.name).to eq(@portfolio.record.name)
      expect(portfolio.user).to eq(@user)
    end
  end

  describe '#destroy!' do
    it 'should destroy dependent positions' do
      # Act
      @portfolio.record.destroy!

      # Assert
      expect(@portfolio.record.positions).to be_empty
    end
  end
end


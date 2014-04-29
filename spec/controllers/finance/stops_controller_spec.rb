require 'spec_helper'

describe Finance::StopsController do
  login
  $symbol = 'ABC'

  describe 'POST create' do
    context 'when position does not exist' do
      it 'fails post creation and redirects to new stop path' do
        post :create, {stop: {symbol: $symbol, percentage: 25}}
        response.should redirect_to new_finance_stop_path
      end
    end

    context 'when percentage is nil' do
      it 'fails post creation and redirects to new stop path' do
        post :create, {stop: {symbol: $symbol}}
        response.should redirect_to new_finance_stop_path
      end
    end

    context 'when percentage is <= 0' do
      it 'fails post creation and redirects to new stop path' do
        post :create, {stop: {symbol: $symbol, percentage: 0}}
        response.should redirect_to new_finance_stop_path
      end
    end

    context 'when all criteria is met' do
      it 'creates a stop and redirects to finance stops path' do
        create(:position, {symbol: $symbol, user: @user})
        Stop.by_user_and_symbol(@user, $symbol).should be_empty

        post :create, {stop: {symbol: $symbol, percentage: 25}}
        stops = Stop.by_user_and_symbol(@user, $symbol)
        stops.should_not be_empty
        stops.size.should eq(1)
        response.should redirect_to finance_stops_path
      end
    end
  end
end


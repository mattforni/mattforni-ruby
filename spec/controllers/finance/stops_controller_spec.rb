require 'spec_helper'

describe Finance::StopsController do
  login
  $symbol = 'ABC'

  describe 'POST create' do
    context 'when symbol is nil' do
      it 'fails post creation and redirects to new stop path' do
        post :create, {stop: {percentage: 0}}

        expect(flash[:alert]).to_not be_nil
        expect(flash[:alert]).to eq(error_on_create(build(:stop, symbol: '')))
        expect(response).to redirect_to new_finance_stop_path
      end
    end

    context 'when percentage is nil' do
      it 'fails post creation and redirects to new stop path' do
        post :create, {stop: {symbol: $symbol}}

        expect(flash[:alert]).to_not be_nil
        expect(flash[:alert]).to eq(error_on_create(build(:stop, symbol: $symbol)))
        expect(response).to redirect_to new_finance_stop_path
      end
    end

    context 'when percentage is <= 0' do
      it 'fails post creation and redirects to new stop path' do
        post :create, {stop: {symbol: $symbol, percentage: 0}}

        expect(flash[:alert]).to_not be_nil
        expect(flash[:alert]).to eq(error_on_create(build(:stop, symbol: $symbol)))
        expect(response).to redirect_to new_finance_stop_path
      end
    end

    context 'when position does not exist' do
      it 'fails post creation and redirects to new stop path' do
        post :create, {stop: {symbol: $symbol, percentage: 25}}

        expect(flash[:alert]).to_not be_nil
        expect(flash[:alert]).to eq(error_on_create(build(:stop, symbol: $symbol)))
        expect(response).to redirect_to new_finance_stop_path
      end
    end

    context 'when all criteria is met' do
      it 'creates a stop and redirects to finance stops path' do
        create(:position, {symbol: $symbol, user: @user})
        Stop.by_user_and_symbol(@user, $symbol).should be_empty

        post :create, {stop: {symbol: $symbol, percentage: 25}}
        stops = Stop.by_user_and_symbol(@user, $symbol)

        expect(stops).to_not be_empty
        expect(stops.size).to eq(1)
        expect(flash[:alert]).to be_nil
        expect(flash[:notice]).to_not be_nil
        expect(flash[:notice]).to eq(success_on_create(stops.first))
        expect(response).to redirect_to finance_stops_path
      end
    end
  end
end


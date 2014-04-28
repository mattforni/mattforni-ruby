require 'spec_helper'

describe Finance::StopsController do
  describe 'POST create' do
    it 'fails and redirects to new finance stop path when position does not exist' do
      post :create, {stop: {symbol: 'ABC', percentage: 25}}

      response.should redirect_to new_finance_stop_path
    end

    it 'fails and redirects to new finance stop path when percentage is nil or <= 0' do
      post :create, {stop: {symbol: 'ABC'}}
      response.should redirect_to new_finance_stop_path

      post :create, {stop: {symbol: 'ABC', percentage: 0}}
      response.should redirect_to new_finance_stop_path
    end

    it 'successfully creates a stop and redirects to finance stops path' do
      post :create, {stop: {symbol: 'ABC', percentage: 25}}
      response.should redirect_to finance_stops_path
    end
  end
end


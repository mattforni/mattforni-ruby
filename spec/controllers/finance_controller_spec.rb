require 'spec_helper'

describe FinanceController do
  describe 'GET last_trade' do
    context 'when format is not json' do
      it 'returns 400' do
        get :last_trade, {symbol: 'ABC'}
        response.status.should eq(400)
      end
    end

    context 'when symbol is invalid' do
      it 'returns 400' do
        get :last_trade, {format: 'json', symbol: 'Invalid'}
        response.status.should eq(400)
      end
    end

    it 'successfully gets the last trade' do
      get :last_trade, {format: 'json', symbol: 'ABC'}
      response.status.should eq(200)
      response.body.should match(/\d+\.\d*/)
    end
  end

  describe 'GET sizing' do
    it 'successfully renders position sizing' do
      get :sizing
      response.status.should eq(200)
    end
  end

  describe 'GET update_stocks' do
    context 'when format is not json' do
      it 'returns 400' do
        get :update_stocks, {token: 'f0rnac0pia'}
        response.status.should eq(400)
      end
    end

    context 'when token is not provided' do
      it 'returns 401' do
        get :update_stocks, {format: 'json'}
        response.status.should eq(401)
      end
    end

    context 'when token is invalid' do
      it 'returns 401' do
        get :update_stocks, {format: 'json', token: 'invalid'}
        response.status.should eq(401)
      end
    end

    it 'successfully updates stocks' do
      get :update_stocks, {format: 'json', token: 'f0rnac0pia'}
      response.status.should eq(200) 
    end
  end
end


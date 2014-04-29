require 'spec_helper'

describe FinanceController do
  describe 'GET last_trade' do
    context 'when format is not json' do
      it 'responds with 400' do
        get :last_trade, {symbol: 'ABC'}
        expect(response.status).to eq(400)
      end
    end

    context 'when symbol is invalid' do
      it 'responds with 400' do
        get :last_trade, {format: 'json', symbol: 'Invalid'}
        expect(response.status).to eq(400)
      end
    end

    context 'when all criteria is met' do
      it 'gets the last trade' do
        get :last_trade, {format: 'json', symbol: 'ABC'}
        expect(response.status).to eq(200)
        expect(response.body).to match(/\d+\.\d*/)
        expect(response.content_type).to eq(Mime::Type.lookup_by_extension(:json))
      end
    end
  end

  describe 'GET sizing' do
    it 'renders position sizing' do
      get :sizing
      expect(response.status).to eq(200)
    end
  end

  describe 'GET update_stocks' do
    context 'when format is not json' do
      it 'responds with 400' do
        get :update_stocks, {token: 'f0rnac0pia'}
        expect(response.status).to eq(400)
      end
    end

    context 'when token is not provided' do
      it 'responds with 401' do
        get :update_stocks, {format: 'json'}
        expect(response.status).to eq(401)
      end
    end

    context 'when token is invalid' do
      it 'responds with 401' do
        get :update_stocks, {format: 'json', token: 'invalid'}
        expect(response.status).to eq(401)
      end
    end

    context 'when all criteria is met' do
      it 'updates stocks' do
        get :update_stocks, {format: 'json', token: 'f0rnac0pia'}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq(Mime::Type.lookup_by_extension(:json))
      end
    end
  end
end


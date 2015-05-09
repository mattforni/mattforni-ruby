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
        # Arrange
        allow(Stocks).to receive(:quote).and_return({lastTrade: nil})

        # Act
        get :last_trade, {format: 'json', symbol: 'invalid'}

        # Assert
        expect(response.status).to eq(400)
      end
    end

    it 'gets the last trade' do
      # Arrange
      last_trade = 1.234
      allow(Stocks).to receive(:quote).and_return({lastTrade: last_trade})

      # Act
      get :last_trade, {format: 'json', symbol: 'abc'}

      # Assert
      expect(response.status).to eq(200)
      expect(response.body).to eq(last_trade.to_s)
      expect(response.content_type).to eq(Mime::Type.lookup_by_extension(:json))
    end
  end

  describe 'GET sizing' do
    it 'renders position sizing' do
      # Arrange / Act
      get :sizing

      # Assert
      expect(response.status).to eq(200)
    end
  end
end


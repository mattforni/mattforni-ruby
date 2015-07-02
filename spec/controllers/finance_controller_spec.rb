require 'spec_helper'

include Stocks

describe FinanceController do
  before(:all) do
    SYMBOL = 'ABC'
  end

  describe 'GET quote' do
    context 'when format is not json' do
      it 'responds with 400' do
        # Act
        get :quote, {symbol: SYMBOL}

        # Assert
        expect(response.status).to eq(400)
      end
    end

    context 'when symbol is invalid' do
      it 'responds with 400' do
        # Arrange
        allow(Quote).to receive(:get).and_return(mock_quote('N/A'))

        # Act
        get :quote, {format: 'json', symbol: SYMBOL}

        # Assert
        expect(response.status).to eq(400)
      end
    end

    it 'gets the quote' do
      # Arrange
      allow(Quote).to receive(:get).and_return(mock_quote)

      # Act
      get :quote, {format: 'json', symbol: SYMBOL}

      # Assert
      parsed = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(response.content_type).to eq(Mime::Type.lookup_by_extension(:json))
      expect(parsed["symbol"]).to eq(SYMBOL)
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

  private

  def mock_quote(name = "#{SYMBOL} Co.")
    quote_response({symbol: SYMBOL, name: name})
  end
end


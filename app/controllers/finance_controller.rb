require 'stocks'

class FinanceController < ApplicationController
  def last_trade
    json_only do
      begin
        render json: Stocks.last_trade(params[:symbol])
      rescue Stocks::RetrievalError
        head 400
      end
    end
  end

  def sizing
  end

  def update_stocks
    json_only do
      # Render a 401 and return if an invalid token is provided
      render json: {}, status: 401 and return if params[:token].nil? or params[:token] != 'f0rnac0pia'
      # Else attempt to update last trade if necessary
      updated = []
      stocks = Stock.all
      stocks.each do |stock|
        if stock.update?
          stock.save!
          updated << stock
        end
      end
      render json: {
        evaluated: stocks.size,
        updated: {number: updated.size, records: updated}
      }
    end
  end
end


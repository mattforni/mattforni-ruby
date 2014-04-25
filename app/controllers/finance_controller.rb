require 'stocks'

class FinanceController < ApplicationController
  def last_trade
    respond_to do |format|
      format.json { render json: Stocks.last_trade(params[:symbol]) }
    end
  end

  def sizing
  end
end


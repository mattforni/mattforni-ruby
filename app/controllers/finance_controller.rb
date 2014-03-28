require 'stocks'

class FinanceController < ApplicationController
  # TODO add back in after analyze in StopsController is functional
  # before_action :authenticate_user!

  def last_trade
    respond_to do |format|
      format.json { render json: Stocks.last_trade(params[:symbol]) }
    end
  end
end


require 'finance'

class FinanceController < ApplicationController
  def index
  end

  def position_sizing
    @a = 100.0 / params[:stop].to_f
    @r = params[:account_size].to_f * (params[:risk].to_f / 100.0)
    @position_size = @r * @a
    # TODO move this into a javascript method instead of the controller
    params[:symbol] = params[:symbol].upcase
    @quote = Finance.get_quote(params[:symbol], [:lastTrade])
    @num_shares = @position_size / @quote[:lastTrade]
  end
end


require 'stocks'

module Finance
  class AjaxController < ApplicationController
    def last_trade 
      respond_to do |format|
        format.json { render json: Stocks.last_trade(params[:symbol]) }
      end
    end
  end
end


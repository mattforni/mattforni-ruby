require 'stocks'

module Finance
	class AjaxController < ApplicationController
		def quote
			@quote = Stocks.get_quote(params[:symbol], [:lastTrade])
			
			# TODO update to reject HTML requests
			respond_to do |format|
				format.json { render json: @quote }
			end
		end
	end
end


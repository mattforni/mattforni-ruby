require 'stocks'

module Finance
	class AjaxController < ApplicationController
		def quote
			@quote = Stocks.get_quote(params[:symbol], [:lastTrade, :date])
      			
			# TODO update to reject HTML requests, maybe clean up json response
			respond_to do |format|
				format.json do 
          if @quote[:date] == Stocks::NA
            render json: {}, status: 400 if @quote[:date] == Stocks::NA
          else
            render json: @quote
          end
        end 
			end
		end
	end
end


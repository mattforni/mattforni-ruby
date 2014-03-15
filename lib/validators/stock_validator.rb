require 'stocks'

module Validators
	class StockValidator < ActiveModel::Validator
		def validate(record)
			if (!Stocks.exists?(record.symbol))
				record.errors[:symbol] << "'#{record.symbol}' is not a valid symbol."
			end
		end
	end
end


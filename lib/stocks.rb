require 'yahoofinance'

module Stocks 
	NA = 'N/A'

	def self.exists?(symbol)
		get_quote(symbol, ['date'])['date'] != NA
	end

  def self.get_quote(symbol, fields)
    data = {}
    # TODO use the fields map to decide which method to use
    standard_quote = YahooFinance::get_standard_quotes(symbol)[symbol]
    fields.each do |field|
      data[field] = standard_quote.send(field)
    end
    data
  end
end


require 'yahoofinance'

# TODO test this module
# TODO add a caching layer with 1-min TTL
module Stocks
	NA = 'N/A'

	def self.exists?(symbol)
		quote(symbol, [:date])[:date] != NA
	end

  def self.last_trade(symbol)
    quote(symbol)[:lastTrade]
  end

  private

  def self.quote(symbol, fields = [:lastTrade])
    data = {}
    # TODO use the fields map to decide which method to use
    standard_quote = YahooFinance::get_standard_quotes(symbol)[symbol]
    fields.each do |field|
      data[field] = standard_quote.send(field) rescue NA
    end
    data
  end
end


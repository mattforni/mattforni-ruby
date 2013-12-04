require 'yahoofinance'
include YahooFinance

module Finance
  FIELDS = {
    :get_standard_quotes => [:lastTrade]
  }

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


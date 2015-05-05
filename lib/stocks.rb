require 'yahoofinance'

# TODO test this module
# TODO add a caching layer with 1-min TTL
module Stocks
  COMMISSION_RANGE = {greater_than_or_equal_to: 0}
  EPSILON = 0.00001
  NA = 'N/A'
  PRICE_RANGE = {greater_than: 0}
  PRICE_SCALE = 5
  PERCENTAGE_RANGE =  {greater_than: 0, less_than: 100}
  QUANTITY_RANGE = {greater_than: 0}

  # TODO move to another lib module
  def self.equal?(value, other)
    (value-other).abs < EPSILON
  end

  def self.exists?(symbol)
    quote(symbol, [:date])[:date] != NA
  end

  def self.last_trade(symbol)
    last_trade = quote(symbol)[:lastTrade]
    raise RetrievalError.new("Could not retrieve last trade for '#{symbol}'") if last_trade == 0 or last_trade == NA
    last_trade
  end

  class RetrievalError < RuntimeError
    def new(message)
      super(message)
    end
  end

  module Historical
    PERIODS = {
      one_month: {label: '1 Month', offset: 1.months},
      three_months: {label: '3 Months', offset: 3.months},
      six_months: {label: '6 Months', offset: 6.months},
      one_year: {label: '1 Year', offset: 1.years},
      five_years: {label: '5 Years', offset: 5.years}
    }

    def self.macd(symbol, days)
      sma12 = self.sma(symbol, 12, days)
      sma26 = self.sma(symbol, 26, days)
      (0...days).collect { |day| sma12[day] - sma26[day] }
    end

    def self.sma(symbol, periods, days)
      sma = []
      days.downto(1).each do |day|
        date = Date.today - day
        quotes = YahooFinance::get_HistoricalQuotes(symbol, date - periods, date)
        sma << quotes.reduce(0) { |total, q| total += q.close } / quotes.size
      end
      sma
    end

    def self.quote(symbol, period)
      raise ArgumentError.new("Period must be provided for a historical quote") if period.nil?
      raise ArgumentError.new("'#{period}' is not a supported period") if !PERIODS.has_key?(period.to_sym)
      YahooFinance::get_HistoricalQuotes(symbol, Date.today - PERIODS[period.to_sym][:offset], Date.today)
    end
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


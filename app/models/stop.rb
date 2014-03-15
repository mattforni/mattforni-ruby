require 'stocks'
require 'validators/stock_validator'

include Validators

class Stop < ActiveRecord::Base
	validates :symbol, presence: true, uniqueness: true
	validates :percentage, presence: true, numericality: {greater_than: 0, less_than: 100}
	validates :stop_price, presence: true
	validates_with StockValidator

  def attempt_update
    new_stop_price = calculate_stop_price
    if new_stop_price > 0 and (stop_price.nil? or stop_price < new_stop_price)
      self.stop_price = new_stop_price
      return true
    end
    false
  end

  private

  def calculate_stop_price
    last_trade = Stocks.last_trade(self.symbol)
    return -1 if last_trade == Stocks::NA
    last_trade * (1.0 - rate)
  end

  def rate
    self.percentage / 100.0
  end
end


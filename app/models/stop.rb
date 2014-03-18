require 'stocks'
require 'validators/stock_validator'

include Validators

class Stop < ActiveRecord::Base
  validates :last_trade, presence: true, numericality: {greater_than: 0}
	validates :percentage, presence: true, numericality: {greater_than: 0, less_than: 100}
	validates :stop_price, presence: true
	validates :symbol, presence: true, uniqueness: true
	validates_with StockValidator

  def update?
    update = update_last_trade?
    update = update_stop_price? or update
  end

  def update_last_trade?
    last_trade = calc_last_trade 
    if last_trade > 0 and (self.last_trade.nil? or self.last_trade != last_trade)
      self.last_trade = last_trade
      return true
    end
    false
  end

  def update_stop_price? 
    stop_price = calc_stop_price
    if stop_price > 0 and (self.stop_price.nil? or self.stop_price < stop_price)
      self.stop_price = stop_price
      return true
    end
    false
  end

  private

  def calc_last_trade
    last_trade = Stocks.last_trade(self.symbol)
    return -1 if last_trade.nil? or last_trade == Stocks::NA
    last_trade
  end

  def calc_stop_price
    return -1 if self.last_trade.nil? 
    self.last_trade * (1.0 - rate)
  end

  def rate
    self.percentage / 100.0
  end
end


require 'stocks'
require 'validators/stock_validator'

include Validators

class Stop < ActiveRecord::Base
  validates :last_trade, presence: true, numericality: {greater_than: 0}
  validates :percentage, presence: true, numericality: {greater_than: 0, less_than: 100}
  validates :stop_price, presence: true
  validates :symbol, presence: true, uniqueness: true
  validates_with StockValidator

  def price_diff
    self.last_trade - self.stop_price
  end

  def stopped_out?
    self.last_trade <= self.stop_price
  end

  def update?
    update_lt = update_last_trade?
    update_sp = update_stop_price?
    update_lt or update_sp
  end

  def update_last_trade?
    last_trade = get_last_trade
    if self.last_trade.nil? or self.last_trade != last_trade
      self.last_trade = last_trade
      return true
    end
    false
  end

  def update_stop_price?
    stop_price = calc_stop_price
    if self.stop_price.nil? or self.stop_price < stop_price
      self.stop_price = stop_price
      self.pinnacle_price = self.last_trade
      self.pinnacle_date = Date.today
      return true
    end
    false
  end

  private

  def get_last_trade
    Stocks.last_trade(self.symbol)
  end

  def calc_stop_price
    update_last_trade? if self.last_trade.nil?
    self.last_trade * (1.0 - rate)
  end

  # TODO protect against percentage being nil
  def rate
    self.percentage / 100.0
  end
end


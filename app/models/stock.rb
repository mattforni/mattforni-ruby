require 'stocks'
require 'validators/stock_validator'

include Stocks
include Validators

class Stock < ActiveRecord::Base
  validates :last_trade, presence: true, numericality: PRICE_RANGE
  validates :symbol, presence: true, uniqueness: true
  validates :highest_price, presence: true, numericality: PRICE_RANGE
  validates :highest_time, presence: true
  validates :last_trade, presence: true, numericality: PRICE_RANGE
  validates :lowest_price, presence: true, numericality: PRICE_RANGE
  validates :lowest_time, presence: true
  validates :symbol, presence: true, uniqueness: true
  validates_with StockValidator

  def update_last_trade?
    last_trade = get_last_trade
    if self.last_trade.nil? or self.last_trade != last_trade
      self.last_trade = last_trade
      return true
    end
    false
  end

  private

  def get_last_trade
    Stocks.last_trade(self.symbol)
  end
end


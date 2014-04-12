require 'stocks'
require 'validators/stock_validator'

include Validators

class Stock < ActiveRecord::Base
  validates :crest_price, presence: true
  validates :crest_time, presence: true
  validates :last_trade, presence: true, numericality: {greater_than: 0}
  validates :symbol, presence: true, uniqueness: true
  validates :trough_price, presence: true
  validates :trough_time, presence: true
  validates_with StockValidator

  has_many :positions

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


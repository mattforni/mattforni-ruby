require 'stocks'
require 'validators/stock_validator'

include Stocks
include Validators

class Stock < ActiveRecord::Base
  validates :highest_price, presence: true, numericality: PRICE_RANGE
  validates :highest_time, presence: true
  validates :last_trade, presence: true, numericality: PRICE_RANGE
  validates :lowest_price, presence: true, numericality: PRICE_RANGE
  validates :lowest_time, presence: true
  validates :symbol, presence: true, uniqueness: true
  validates_with StockValidator

  # TODO test these associations
  has_many :positions
  has_many :holdings, through: :positions

  def self.by_symbol(symbol)
    Stock.where({symbol: symbol}).first
  end

  def update?(force = false)
    begin
      update = false
      last_trade = get_last_trade
      # If last_trade has not been set or has changed, update it
      if self.last_trade.nil? or !Stocks.equal?(self.last_trade, last_trade)
        self.last_trade = last_trade
        # If last_trade is less than the current lowest_price, update it
        # TODO change >/< to use a signif digit comparisson operator
        # TODO test that these are updated in different cases
        # TODO abstract this into a module for generic use
        if self.lowest_price.nil? or self.last_trade < self.lowest_price
          self.lowest_price = self.last_trade
          self.lowest_time = Time.now.utc
        end

        # If last_trade is greater than the current highest_price, update it
        if self.highest_price.nil? or self.last_trade > self.highest_price
          self.highest_price = self.last_trade
          self.highest_time = Time.now.utc
        end

        update = true
      end

      # Update holdings if the stock was updated or force is set
      if (update or force)
        self.holdings.each { |holding| holding.save! if holding.update? }
      end
    rescue RetrievalError
      logger.error "Unable to retrieve last trade for #{self.symbol}"
    end
    update
  end

  private

  def get_last_trade
    Stocks.last_trade(self.symbol)
  end
end


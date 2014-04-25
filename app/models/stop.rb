require 'stocks'

include Stocks

class Stop < ActiveRecord::Base
  validates :highest_price, presence: true, numericality: PRICE_RANGE
  validates :highest_time, presence: true
  validates :percentage, presence: true, numericality: PERCENTAGE_RANGE
  validates :position_id, presence: true
  validates :stop_price, presence: true, numericality: PRICE_RANGE
  validates :symbol, presence: true
  validates :lowest_price, presence: true, numericality: PRICE_RANGE
  validates :lowest_time, presence: true
  validates :user_id, presence: true

  belongs_to :position
  belongs_to :user

  delegate :stock, to: :position, allow_nil: false
  delegate :last_trade, to: :stock, allow_nil: false

  def price_diff
    self.last_trade - self.stop_price
  end

  def stopped_out?
    self.last_trade <= self.stop_price
  end

  def update?
    update = false
    stop_price = calc_stop_price
    # If stop_price has not been set or has gone up, update it
    if self.stop_price.nil? or self.stop_price < stop_price
      self.stop_price = stop_price
      update = true
    end
    # If delegated last_trade is less than the current lowest_price, update it
    if self.lowest_price.nil? or self.last_trade < self.lowest_price
      self.lowest_price = self.last_trade
      self.lowest_time = Time.now.utc
      update = true
    end
    # If delegated last_trade is greater than the current highest_price, update it
    if self.highest_price.nil? or self.last_trade > self.highest_price
      self.highest_price = self.last_trade
      self.highest_time = Time.now.utc
      update = true
    end
    update
  end

  private

  def calc_stop_price
    self.stock.update? if self.last_trade.nil?
    self.last_trade * (1.0 - rate)
  end

  # TODO protect against percentage being nil
  def rate
    self.percentage / 100.0
  end
end


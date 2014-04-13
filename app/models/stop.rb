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

  def update_stop_price?
    stop_price = calc_stop_price
    if self.stop_price.nil? or self.stop_price < stop_price
      self.stop_price = stop_price
      self.highest_price = self.last_trade
      self.highest_time = Time.now.utc
      return true
    end
    false
  end

  private

  def calc_stop_price
    self.stock.update_last_trade? if self.last_trade.nil?
    self.last_trade * (1.0 - rate)
  end

  # TODO protect against percentage being nil
  def rate
    self.percentage / 100.0
  end
end


class Stop < ActiveRecord::Base
  validates :percentage, presence: true, numericality: {greater_than: 0, less_than: 100}
  validates :position_id, presence: true
  validates :stop_price, presence: true
  validates :symbol, presence: true
  validates :user_id, presence: true

  belongs_to :position
  belongs_to :user

  #TODO delegate :stock, to: :position, allow_nil: false
  #TODO delegate :last_trade, to: :stock, allow_nil: false

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
      self.pinnacle_price = self.last_trade
      self.pinnacle_date = Date.today
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


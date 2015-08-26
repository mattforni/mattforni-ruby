# TODO test create!, update?
class Holding < ActiveRecord::Base
  validates :commission_price, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :position_id, presence: true
  validates :purchase_date, presence: true
  validates :purchase_price, presence: true, numericality: {greater_than: 0}
  validates :quantity, presence: true, numericality: {greater_than: 0}
  validates :symbol, presence: true
  validates :user_id, presence: true

  attr_accessor :creation_portfolio

  belongs_to :position
  belongs_to :user

  delegate :portfolio, to: :position, allow_nil: false
  delegate :stock, to: :position, allow_nil: false
  delegate :last_trade, to: :stock, allow_nil: false

  def create!
    self.transaction do
      # Check if there is already a stock model for this symbol
      stock = Stock.by_symbol(symbol)

      # If there is not already a stock model then attempt to create one
      if stock.nil?
        stock = Stock.new({symbol: self.symbol})
        stock.update!
      end

      # Check if there is already a position model for this user and symbol
      position = Position.by_portfolio_and_symbol(self.creation_portfolio, symbol)
      position_existed = true
      # If there is not already a position then attempt to create one
      if position.nil?
        position_existed = false
        position = Position.new({
          commission_price: self.commission_price,
          purchase_price: self.purchase_price,
          quantity: self.quantity,
          symbol: self.symbol
        })
        position.portfolio = self.creation_portfolio
        position.stock = stock
        position.user = self.user
        position.save!
      end
      self.position = position

      # Update tracking data to defaults
      last_trade = position.last_trade
      updated_at = position.updated_at
      self.highest_price = last_trade
      self.highest_time = updated_at
      self.lowest_price = last_trade
      self.lowest_time = updated_at

      # Attempt to save the new holding model
      self.save!

      # Update the existing position if necessary
      position.update! if position_existed
    end
  end

  def current_value
    self.last_trade * self.quantity - self.commission_price
  end

  def destroy!
    self.transaction do
      # Destroy self.
      self.destroy

      # Destroy the associated position.
      self.position.update!

      # If the portfolio no longer has any positions, delete it as well.
      self.portfolio.destroy! if self.portfolio.positions.empty?
    end
  end

  def total_change
    self.current_value - self.purchase_price * self.quantity
  end

  def update?
    update = false

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
end


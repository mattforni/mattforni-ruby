class Holding < ActiveRecord::Base
  validates :commission_price, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :position_id, presence: true
  validates :purchase_date, presence: true
  validates :purchase_price, presence: true, numericality: {greater_than: 0}
  validates :quantity, presence: true, numericality: {greater_than: 0}
  validates :symbol, presence: true
  validates :user_id, presence: true

  belongs_to :position
  belongs_to :user

  delegate :stock, to: :position, allow_nil: false

  def create!
    Holding.transaction do
      # Check if there is already a stock model for this symbol
      stock = Stock.by_symbol(symbol)
      # If there is not already a stock model then attempt to create one
      if stock.nil?
        stock = Stock.new({symbol: self.symbol})
        stock.update?
        stock.save!
      end

      # Check if there is already a position model for this user and symbol
      position = Position.by_user_and_symbol(self.user, symbol)
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
        position.stock = stock
        position.user = self.user
        position.save!
      end

      # Attempt to save the new holding model
      self.position = position
      self.save!

      # Update the existing position if necessary
      if position_existed
        position.update_weighted_avg!(:commission_price)
        position.update_weighted_avg!(:purchase_price)
        position.increment(:quantity, self.quantity)
      end
    end
  end
end


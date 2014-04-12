class Position < ActiveRecord::Base
  validates :commission_price, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :purchase_price, presence: true, numericality: {greater_than: 0}
  validates :quantity, presence: true, numericality: {greater_than: 0}
  validates :stock_id, presence: true
  validates :symbol, presence: true
  validates :user_id, presence: true

  belongs_to :stock
  belongs_to :user

  #TODO delegate :last_trade, to: :stock, allow_nil: false
end


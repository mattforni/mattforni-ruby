require 'stocks'

include Stocks

class Position < ActiveRecord::Base
  validates :commission_price, presence: true, numericality: COMMISSION_RANGE
  validates :purchase_price, presence: true, numericality: PRICE_RANGE
  validates :quantity, presence: true, numericality: QUANTITY_RANGE 
  validates :stock_id, presence: true
  validates :symbol, presence: true
  validates :user_id, presence: true

  belongs_to :stock
  belongs_to :user

  delegate :last_trade, to: :stock, allow_nil: false
end


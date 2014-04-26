require 'stocks'

include Stocks

class Position < ActiveRecord::Base
  WEIGHTED_ATTRIBUTES = [:commission_price, :purchase_price]

  validates :commission_price, presence: true, numericality: COMMISSION_RANGE
  validates :purchase_price, presence: true, numericality: PRICE_RANGE
  validates :quantity, presence: true, numericality: QUANTITY_RANGE 
  validates :stock_id, presence: true
  validates :symbol, presence: true
  validates :user_id, presence: true

  belongs_to :stock
  belongs_to :user

  has_many :holdings

  delegate :last_trade, to: :stock, allow_nil: false

  def self.by_user_and_symbol(user, symbol)
    Position.where({user_id: user.id, symbol: symbol}).first
  end

  def update_weighted_avg!(attribute)
    if !WEIGHTED_ATTRIBUTES.include?(attribute)
      raise ArgumentError.new("#{attribute} is not a valid weighted attribute")
    end
    shares = 0
    weighted = self.holdings(true).reduce(0) do |total, holding|
      shares += holding.quantity
      total += holding.quantity * holding.send(attribute)
    end
    self.send("#{attribute}=", weighted/shares)
  end
end


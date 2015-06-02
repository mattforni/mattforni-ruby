require 'ranges'
require 'stocks'

include Ranges
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
  has_many :stops

  delegate :last_trade, to: :stock, allow_nil: false

  def self.by_user_and_symbol(user, symbol)
    Position.where({user_id: user.id, symbol: symbol}).first
  end

  def current_value
    self.last_trade * self.quantity - self.commission_price
  end

  def highest_price
    return @high_price if !@high_price.nil?
    high_price = self.holdings.reduce(nil) do |highest, holding|
      highest = holding.highest_price if highest.nil? or holding.highest_price > highest
      highest
    end
    @high_price = high_price
  end

  def lowest_price
    return @low_price if !@low_price.nil?
    low_price = self.holdings.reduce(nil) do |lowest, holding|
      lowest = holding.lowest_price if lowest.nil? or holding.lowest_price < lowest
      lowest
    end
    @low_price = low_price
  end

  def stop
    self.stops.first
  end

  def total_change
    self.current_value - self.purchase_price * self.quantity
  end

  def update!
    self.update_weighted_avg!(:purchase_price)
    total_commission_price = 0
    total_quantity = 0
    self.holdings(true).each do |holding|
      total_commission_price += holding.commission_price
      total_quantity += holding.quantity
    end
    self.commission_price = total_commission_price
    self.quantity = total_quantity
    self.save!
  end

  def update_weighted_avg!(attribute)
    if !WEIGHTED_ATTRIBUTES.include?(attribute)
      raise ArgumentError.new("#{attribute} is not a valid weighted attribute")
    end
    shares = 0
    # Discard the cached holdings and get the latest
    weighted = self.holdings(true).reduce(0) do |total, holding|
      shares += holding.quantity
      total += holding.quantity * holding.send(attribute)
    end
    self.send("#{attribute}=", weighted/shares)
  end

  private

  attr_writer :high_price
  attr_writer :low_price
end


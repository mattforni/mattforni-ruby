require 'ranges'
require 'stocks'

include Ranges
include Stocks

class Position < ActiveRecord::Base
  validates :commission_price, presence: true, numericality: COMMISSION_RANGE
  validates :portfolio_id, presence: true
  validates :purchase_price, presence: true, numericality: PRICE_RANGE
  validates :quantity, presence: true, numericality: QUANTITY_RANGE
  validates :stock_id, presence: true
  validates :symbol, presence: true
  validates :user_id, presence: true

  belongs_to :portfolio
  belongs_to :stock
  belongs_to :user

  # TODO for some reason cascading deletion is not working in testing
  has_many :holdings, dependent: :destroy
  has_many :stops, dependent: :destroy

  delegate :last_trade, to: :stock, allow_nil: false

  def self.by_portfolio_and_symbol(portfolio, symbol)
    Position.where(portfolio: portfolio, symbol: symbol).first
  end

  def self.by_user_and_symbol(user, symbol)
    Position.where({user_id: user.id, symbol: symbol}).first
  end

  def cost_basis
    self.purchase_price * self.quantity + self.commission_price
  end

  def current_value
    self.last_trade * self.quantity
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
    self.current_value - self.cost_basis
  end

  def total_change_percent
    self.total_change / self.cost_basis * 100.to_f
  end

  def update!
    total_commission_price = 0
    total_quantity = 0
    total_weighted = 0

    # Discard the cached holdings and get the latest
    self.holdings(true).each do |holding|
      total_commission_price += holding.commission_price
      total_quantity += holding.quantity
      total_weighted += holding.quantity * holding.purchase_price
    end

    self.destroy! and return if total_quantity == 0

    self.commission_price = total_commission_price
    self.purchase_price = total_weighted / total_quantity
    self.quantity = total_quantity

    self.save!
  end

  private

  attr_writer :high_price
  attr_writer :low_price
end


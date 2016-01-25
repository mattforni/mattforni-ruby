require 'ranges'

class Alert < ActiveRecord::Base 
  belongs_to :stock
  belongs_to :user

  delegate :last_trade, to: :stock, allow_nil: false
  delegate :symbol, to: :stock, allow_nil: false

  validates :active, presence: true
  validates :greater_than, numericality: {greater_than: 0}
  validates :less_than, numericality: {greater_than: 0}
  validates :stock_id, presence: true
  validates :user_id, presence: true

  validates_with Ranges::AlertValidator

  def to_s
    parts = ["Alert on #{self.symbol}: "]
    case self.type.to_sym
    when :greater_than
      parts << "(#{self.greater_than} < #{self.last_trade})"
    when :less_than
      parts << "(#{self.last_trade} < #{self.less_than})"
    when :range
      parts << "(#{self.greater_than} < #{self.last_trade} < #{self.less_than})"
    end
    parts.join(' ')
  end

  def trigger?
    case self.type.to_sym
    when :greater_than
      if self.greater_than > self.last_trade
        self.active = false
      end
    when :less_than
       if self.last_trade > self.less_than
        self.active = false
      end     
    when :range
      if self.greater_than > self.last_trade or self.last_trade > self.less_than
        self.active = false
      end
    end

    if !self.active
      self.triggered_at = Time.now.utc
      return true
    end

    return false
  end

  def type 
    return TYPE[:range] if !(self.greater_than.nil? or self.less_than.nil?)
    return self.greater_than.nil? ? TYPE[:less_than] : TYPE[:greater_than]
  end

  private

  TYPE = {
    greater_than: 'greater_than',
    less_than: 'less_than',
    range: 'range'
  }
end


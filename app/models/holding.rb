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

  #TODO delegate :stock, to: :position, allow_nil: false
end


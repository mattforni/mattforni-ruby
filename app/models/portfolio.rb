class Portfolio < ActiveRecord::Base
  DEFAULT_NAME = 'cash-money'
  UNIQUENESS_ERROR = 'must be unique for a given user'

  validates :name, presence: true, uniqueness: {
    scope: [:user_id],
    message: UNIQUENESS_ERROR
  }
  validates :user_id, presence: true

  belongs_to :user

  has_many :positions

  def self.default(user)
    raise 'Must provider a user to the default portfolio query' if user.nil?
    default_portfolio = Portfolio.where(user: user).first
    raise "Unable to retrieve default portfolio for '#{user.email}'" if default_portfolio.nil?
    default_portfolio
  end

  def current_value
    return @curr_value if !@curr_value.nil?
    curr_value = self.positions.reduce(0) do |value, position|
      value += position.current_value
      value
    end
    @curr_value = curr_value
  end

  def total_change
    return @tot_change if !@tot_change.nil?
    tot_change = self.positions.reduce(0) do |change, position|
      change += position.total_change
      change
    end
    @tot_change = tot_change
  end

  private

  attr_writer :curr_value
  attr_writer :tot_change
end


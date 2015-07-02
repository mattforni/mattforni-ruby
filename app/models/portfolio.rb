class Portfolio < ActiveRecord::Base
  DEFAULT_NAME = 'cash-money'
  DOES_NOT_EXIST = "Portfolio does not exist for user '%s'"
  UNIQUENESS_ERROR = 'must be unique for a given user'

  validates :name, presence: true, uniqueness: {
    scope: [:user_id],
    message: UNIQUENESS_ERROR
  }
  validates :user_id, presence: true

  belongs_to :user

  has_many :positions

  def self.by_user_and_id(user, id)
    raise 'Must provide a user to query for a portfolio' if user.nil?
    portfolio = Portfolio.where(user: user, id: id).first
    raise ActiveRecord::RecordNotFound if portfolio.nil?
    portfolio
  end

  def self.default(user)
    raise 'Must provide a user to query for a portfolio' if user.nil?
    portfolio = Portfolio.where(user: user).first
    raise ActiveRecord::RecordNotFound if portfolio.nil?
    portfolio
  end

  def create!
    save!
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

  MISSING_USER = 'Must provide a user to query for a portfolio'

  def require_user(user)
    raise ArgumentError.new(MISSING_USER) if user.nil?
  end

  attr_writer :curr_value
  attr_writer :tot_change
end


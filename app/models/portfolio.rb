class Portfolio < ActiveRecord::Base
  DEFAULT_NAME = 'stacks'
  DOES_NOT_EXIST = "Portfolio does not exist for user '%s'"
  UNIQUENESS_ERROR = 'must be unique for a given user'

  validates :name, presence: true, uniqueness: {
    scope: [:user_id],
    message: UNIQUENESS_ERROR
  }
  validates :user_id, presence: true

  belongs_to :user

  has_many :positions, dependent: :destroy

  def self.by_user_and_id(user, id)
    raise 'Must provide a user to query for a portfolio' if user.nil?
    portfolio = Portfolio.where(user: user, id: id).first
    raise ActiveRecord::RecordNotFound if portfolio.nil?
    portfolio
  end

  def self.by_user_and_name(user, name)
    raise 'Must provide a user to query for a portfolio' if user.nil?
    portfolio = Portfolio.where(user: user, name: name).first
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

  def cost_basis
    return @cost if !@cost.nil?
    cost = self.positions.reduce(0) do |value, position|
      value += position.cost_basis
      value
    end
    @cost = cost
  end

  def current_value
    return @curr_value if !@curr_value.nil?
    curr_value = self.positions.reduce(0) do |value, position|
      value += position.current_value
      value
    end
    @curr_value = curr_value
  end

  def to_s
    "#{self.user.email} - #{self.name}"
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

  attr_writer :cost
  attr_writer :curr_value
  attr_writer :tot_change
end


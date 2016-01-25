class User < ActiveRecord::Base
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true

  has_many :alerts, dependent: :destroy
  has_many :holdings, dependent: :destroy
  has_many :portfolios, dependent: :destroy
  has_many :positions, dependent: :destroy
  has_many :stops, dependent: :destroy

  def current_value
    return @curr_value if !@curr_value.nil?
    curr_value = self.positions.reduce(0) do |value, position|
      value += position.current_value
      value
    end
    @curr_value = curr_value
  end

  def default_portfolio
    Portfolio.default(self)
  end

  private

  attr_writer :curr_value
end


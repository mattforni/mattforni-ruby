class User < ActiveRecord::Base
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true

  has_many :holdings, dependent: :destroy
  has_many :portfolios, dependent: :destroy
  has_many :positions, dependent: :destroy
  has_many :stops, dependent: :destroy

  def default_portfolio
    Portfolio.default(self)
  end
end


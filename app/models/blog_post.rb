class BlogPost < ActiveRecord::Base 
  validates :content, presence: true
  validates :short_url, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true

  def create!
    self.save!
  end
end


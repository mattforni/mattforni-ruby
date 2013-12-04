class Post < ActiveRecord::Base
  # TODO validate parameters before creation

  def to_s
    "Post (#{self.id}): '#{self.title}'"
  end
end


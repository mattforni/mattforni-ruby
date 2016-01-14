require 'spec_helper'

describe BlogPost do
  validates = {
    presence: [
      :content,
      :short_url,
      :title
    ],
    uniqueness: [
      :short_url,
      :title
    ]
  }

  before(:each) do
    @blog_post = Record.validates(create :blog_post)
  end

  describe 'validates' do
    validates.each_pair do |type, fields|
      fields.each do |field|
        it "#{type} of :#{field}" do
          @blog_post.send "field_#{type}", field
        end
      end
    end
  end
end


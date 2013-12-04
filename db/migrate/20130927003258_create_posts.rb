class CreatePosts < ActiveRecord::Migration
  def self.up 
    create_table :posts do |t|
      t.string :title, :null => false
      t.string :short_url, :null => false
      t.string :description
      t.text :content, :null => false

      t.timestamps
    end

    add_index :posts, :title, :unique => true, :name => 'post_title_uniqueness'
    add_index :posts, :short_url, :unique => true, :name => 'post_short_url_uniqueness'
    add_index :posts, :content, :length => 255, :name => 'post_content_index'
  end

  def self.down
    drop_table :blog_posts
  end
end


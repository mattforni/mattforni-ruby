class CreateBlogPosts < ActiveRecord::Migration
  def change
    # Drop the old tables
    drop_table :posts
    drop_table :taggings
    drop_table :tags

    # Create the new table
    create_table :blog_posts do |t|
      t.text :content, :null => false
      t.string :description
      t.string :short_url, :null => false
      t.string :title, :null => false

      t.timestamps
    end

    add_index :blog_posts, :title, unique: true, name: 'blog_post_title_uniqueness'
    add_index :blog_posts, :short_url, unique: true, name: 'blog_post_short_url_uniqueness'
    add_index :blog_posts, :content, length: 255, name: 'blog_post_content_index'
  end
end


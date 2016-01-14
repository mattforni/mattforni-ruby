class BlogPostsController < ApplicationController
  authorize_resource

  def create
    params = blog_post_params
    @blog_post = BlogPost.new params 
    attempt_create! @blog_post, root_path, new_blog_post_path({blog_post: params})
  end

  def new
    params = blog_post_params if params and !params.empty?
    @blog_post = BlogPost.new params
  end

  private

  def blog_post_params
    params.require(:blog_post).permit(
      :content,
      :description,
      :short_url,
      :title
    )
  end
end


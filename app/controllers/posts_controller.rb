class PostsController < ApplicationController
  before_action :set_post, except: [:new, :create]

  def new
    @post = Post.new
    respond_to do |format|
      format.html { render status: 200 }
    end
  end

  def create
    # TODO look into strong parameters for rails 4
    @post = Post.new(post_params)
    if @post.save!
      # TODO log success
      respond_to do |format|
        format.html { redirect_to @post }
      end
    else
      # TODO log failure and redirect to new with params
      # TODO add render calls and status codes
    end
  end

  def destroy
    if @post.destroy!
      # TODO log success 
      # TODO add render calls and status codes
      respond_to do |format|
        format.html { redirect_to root_url }
      end
    else
      # TODO log blog post destruction failure
    end
  end

  def edit
    respond_to do |format|
      format.html { render status: 200 }
    end
  end

  def show
    # TODO for show, search by short_url instead of id
    respond_to do |format|
      format.html { render status: 200 }
    end
  end

  def update
    if @post.update_attributes!(post_params)
      # TODO log success and redirect to show blog post page 
      puts "#{@post.to_s} created successfully."
      redirect_to @post
    else
      # TODO log failure and redirect to new with params
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :short_url, :description, :content)
  end
end


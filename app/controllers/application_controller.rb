class ApplicationController < ActionController::Base
  before_action :set_user 
  layout 'application'

  def splash
    @posts = Post.all.order("created_at DESC") rescue []
    respond_to do |format|
      format.html { render status: 200 }
    end
  end

  private

  def set_user
    @user = current_user
  end
end


class ApplicationController < ActionController::Base
  layout 'application'

  def splash
    @posts = Post.all.order("created_at DESC") rescue []
    respond_to do |format|
      format.html { render status: 200 }
    end
  end
end


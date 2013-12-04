class ApplicationController < ActionController::Base
  layout 'application'
  helper_method :current_user_session, :current_user

  def splash
    @posts = Post.all.order("created_at DESC") rescue []
    respond_to do |format|
      format.html { render status: 200 }
    end
  end

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
end


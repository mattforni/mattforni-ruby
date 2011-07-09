class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :safe_execute
  
  def safe_execute
    @view_path = File.join(params[:controller], params[:action])
    puts "going through safe execute"
    yield
  rescue => exc
    puts exc
    ##TODO figure out logger and put it in here
  end
  
end

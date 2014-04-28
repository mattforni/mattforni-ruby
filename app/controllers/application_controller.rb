class ApplicationController < ActionController::Base
  layout 'application'

  def splash
    @posts = Post.all.order("created_at DESC") rescue []
    respond_to do |format|
      format.html { render status: 200 }
    end
  end

  protected

  def json_only
    raise ArgumentError.new('Block must be provided') if !block_given?
    respond_to do |format|
      format.json do
        yield
      end
      format.all { head 400 }
    end
  end
end


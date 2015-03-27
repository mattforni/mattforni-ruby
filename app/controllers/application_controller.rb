class ApplicationController < ActionController::Base
  layout 'application'
  rescue_from CanCan::AccessDenied, with: :access_denied
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::UnknownFormat do
    head 406
  end

  def splash
    @posts = Post.all.order("created_at DESC") rescue []
    respond_to do |format|
      format.html { render status: 200 }
    end
  end

  module Messages
    CREATE = 'create'
    DESTROY = 'destroy'
    UPDATE = 'update'

    def record_error(action, record)
      generate_message ERROR_MESSAGE, action, record
    end

    def record_success(action, record)
      generate_message SUCCESS_MESSAGE, action, record
    end

    private

    def generate_message(template, action, record)
      # If the record has a non-null, non-empty 'symbol' as an attribute add it to the message
      additional = record.respond_to?(:symbol) and record.symbol and !record.symbol.empty? ? " for #{record.symbol}" : ''
      template % {action: action, record: record.class.to_s.downcase, additional: additional}
    end

    ERROR_MESSAGE = "Unable to %{action} %{record}%{additional}."
    SUCCESS_MESSAGE = "Successfully %{action} %{record}%{additional}."
  end

  protected

  def json_only
    raise ArgumentError.new('Block must be provided') if !block_given?
    respond_to do |format|
      format.json { yield }
      format.all { head 400 }
    end
  end

  private

  def access_denied
    head 401
  end

  def record_not_found(exception)
    flash[:alert] = exception.message
    begin
      redirect_to :back
    rescue ActionController::RedirectBackError
      redirect_to root_url
    end
  end
end


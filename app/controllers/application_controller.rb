class ApplicationController < ActionController::Base
  layout 'application'
  rescue_from CanCan::AccessDenied, with: :access_denied
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def splash
    @posts = Post.all.order("created_at DESC") rescue []
    respond_to do |format|
      format.html { render status: 200 }
    end
  end

  module Messages
    def error_on_create(record)
      generate_message CREATE_ERROR_MESSAGE, record
    end

    def error_on_destroy(record)
      generate_message DESTROY_ERROR_MESSAGE, record
    end

    def error_on_update(record)
      generate_message UPDATE_ERROR_MESSAGE, record
    end

    def success_on_create(record)
      generate_message CREATE_SUCCESS_MESSAGE, record
    end

    def success_on_destroy(record)
      generate_message DESTROY_SUCCESS_MESSAGE, record
    end

    def success_on_update(record)
      generate_message UPDATE_SUCCESS_MESSAGE, record
    end

    private

    def generate_message(template, record)
      additional = ''
      if (record.respond_to?(:symbol)
        symbol = record.symbol
        additional = " for #{record.symbol}" if !(record.symbol.nil? or record.symbol.empty?))
      end
      template % {record: record.class.to_s.downcase, additional: additional}
    end

    CREATE_ERROR_MESSAGE = "Unable to create %{record}%{additional}."
    CREATE_SUCCESS_MESSAGE = "Successfully created %{record}%{additional}."
    DESTROY_ERROR_MESSAGE = "Unable to destroy %{record}%{additional}."
    DESTROY_SUCCESS_MESSAGE = "Successfully destroyed %{record}%{additional}."
    UPDATE_ERROR_MESSAGE = "Unable to update %{record}%{additional}."
    UPDATE_SUCCESS_MESSAGE = "Successfully updated %{record}%{additional}."
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


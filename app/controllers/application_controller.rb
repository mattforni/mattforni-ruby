class ApplicationController < ActionController::Base
  layout 'application'
  rescue_from CanCan::AccessDenied, with: :access_denied
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::UnknownFormat do
    head 406
  end

  def splash
    @blog_posts = BlogPost.all.order("created_at DESC") rescue []
    respond_to do |format|
      format.html { render status: 200 }
    end
  end

  module Messages
    CREATE = {error: 'create', success: 'created'}
    DESTROY = {error: 'destroy', success: 'destroyed'}
    UPDATE = {error: 'update', success: 'updated'}

    def self.record_error(action, record)
      generate_message ERROR_MESSAGE, action[:error], record
    end

    def self.record_success(action, record)
      generate_message SUCCESS_MESSAGE, action[:success], record
    end

    private

    def self.generate_message(template, action, record)
      # If the record has a non-null, non-empty 'symbol' as an attribute add it to the message
      additional = (record.respond_to?(:symbol) and record.symbol and !record.symbol.empty?) ? " for #{record.symbol}" : ''
      template % {action: action, record: record.class.to_s.downcase, additional: additional}
    end

    ERROR_MESSAGE = "Unable to %{action} %{record}%{additional}."
    SUCCESS_MESSAGE = "Successfully %{action} %{record}%{additional}."
  end

  protected

  def attempt_create!(record, success_redirect, failure_redirect)
    begin
      record.create!
      flash[:notice] = Messages.record_success(Messages::CREATE, record)
      redirect_to success_redirect and return
    rescue ActiveRecord::RecordInvalid
      error_message = Messages.record_error(Messages::CREATE, $!.record)
      logger.error "#{error_message} - #{$!.record.errors.full_messages.join(', ')}"
      flash[:alert] = error_message
      flash[:errors] = $!.record.errors.full_messages
      redirect_to failure_redirect and return
    end
  end

  def attempt_destroy!(record, success_redirect, failure_redirect = nil)
    failure_redirect ||= success_redirect
    begin
      record.destroy!
      flash[:notice] = Messages.record_success(Messages::DESTROY, record)
      redirect_to success_redirect and return
    rescue ActiveRecord::RecordInvalid
      error_message = Messages.record_error(Messages::DESTROY, $!.record)
      logger.error "#{error_message} - #{$!.record.errors.full_messages.join(', ')}"
      flash[:alert] = error_message
      flash[:errors] = $!.record.errors.full_messages
      redirect_to failure_redirect and return
    end
  end

  def attempt_update!(record, success_redirect, failure_redirect)
    begin
      record.save!
      flash[:notice] = Messages.record_success(Messages::UPDATE, record)
      redirect_to success_redirect and return
    rescue ActiveRecord::RecordInvalid
      error_message = Messages.record_error(Messages::UPDATE, $!.record)
      logger.error "#{error_message} - #{$!.record.errors.full_messages.join(', ')}"
      flash[:alert] = error_message
      flash[:errors] = $!.record.errors.full_messages
      redirect_to failure_redirect and return
    end
  end

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


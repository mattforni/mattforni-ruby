class ApplicationController < ActionController::Base
  layout 'application'
  rescue_from CanCan::AccessDenied, with: :access_denied

  def splash
    @posts = Post.all.order("created_at DESC") rescue []
    respond_to do |format|
      format.html { render status: 200 }
    end
  end

  module Messages
    def error_on_create(record)
      additional = ''
      if (record.respond_to?(:symbol)
        symbol = record.symbol
        additional = " for #{record.symbol}" if !(record.symbol.nil? or record.symbol.empty?))
      end
      CREATE_ERROR_MESSAGE % {record: record.class.to_s.downcase, additional: additional}
    end

    def success_on_create(record)
      additional = ''
      if (record.respond_to?(:symbol)
        symbol = record.symbol
        additional = " for #{record.symbol}" if !(record.symbol.nil? or record.symbol.empty?))
      end
      CREATE_SUCCESS_MESSAGE % {record: record.class.to_s.downcase, additional: additional}
    end

    private

    CREATE_ERROR_MESSAGE = "Unable to create %{record}%{additional}."
    CREATE_SUCCESS_MESSAGE = "Successfully created %{record}%{additional}"
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
end


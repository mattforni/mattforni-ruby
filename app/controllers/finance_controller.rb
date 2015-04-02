require 'stocks'

class FinanceController < ApplicationController
  include Messages
  include Stocks

  before_action :authenticate_user!, only: [:positions]
  around_action :json_only, only: [:historical, :last_trade]

  def charts
    @period = params[:period] || DEFAULT_PERIOD
    @periods = Historical::PERIODS
    @symbol = params[:symbol].upcase

    historical_data = get_historical_data(@symbol, @period) do
      logger.error $!.message
      flash[:alert] = $!.message
      redirect_to charts_path @symbol and return
    end
    gon.max = historical_data[:max]
    gon.min = historical_data[:min]
    gon.time_series_data = historical_data[:time_series_data]
    gon.symbol = @symbol
    gon.period = @period
  end

  def historical
    period = params[:period] || DEFAULT_PERIOD
    symbol = params[:symbol].upcase
    historical_data = get_historical_data(symbol, period) do
      logger.error $!.message
      head 400 and return
    end
    render json: historical_data if historical_data
  end

  def index
  end

  def last_trade
    begin
      render json: Stocks.last_trade(params[:symbol])
    rescue Stocks::RetrievalError
      head 400
    end
  end

  def positions
    @positions = Position.where(user_id: current_user.id).order(:symbol)
    @total_value = @positions.reduce(0) do |total, position|
      total += position.current_value
    end
  end

  def sizing
  end

  def update_stocks
    json_only do
      # Render a 401 and return if an invalid token is provided
      render json: {}, status: 401 and return if Rails.env.production? && params[:token] != 'f0rnac0pia'
      # Else attempt to update last trade if necessary
      updated = []
      stocks = Stock.all
      stocks.each { |stock| updated << stock if stock.update! }
      render json: {
        evaluated: stocks.size,
        updated: { number: updated.size, records: updated.collect { |u| {symbol: u.symbol, last_trade: u.last_trade} } }
      }
    end
  end

  protected

  def attempt_create!(record, success_redirect, failure_redirect)
    begin
      record.create!
      flash[:notice] = record_success(CREATE, record)
      redirect_to success_redirect and return
    rescue ActiveRecord::RecordInvalid
      error_message = record_error(CREATE, $!.record)
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
      flash[:notice] = record_success(DESTROY, record)
      redirect_to success_redirect and return
    rescue ActiveRecord::RecordInvalid
      error_message = record_error(DESTROY, $!.record)
      logger.error "#{error_message} - #{$!.record.errors.full_messages.join(', ')}"
      flash[:alert] = error_message
      flash[:errors] = $!.record.errors.full_messages
      redirect_to failure_redirect and return
    end
  end

  def attempt_update!(record, success_redirect, failure_redirect)
    begin
      record.save!
      flash[:notice] = record_success(UPDATE, record)
      redirect_to success_redirect and return
    rescue ActiveRecord::RecordInvalid
      error_message = record_error(UPDATE, $!.record)
      logger.error "#{error_message} - #{$!.record.errors.full_messages.join(', ')}"
      flash[:alert] = error_message
      flash[:errors] = $!.record.errors.full_messages
      redirect_to failure_redirect and return
    end
  end

  private

  DEFAULT_PERIOD = 'six_months'

  def get_historical_data(symbol, period, &error_handler)
    begin
      max = Float::MIN
      min = Float::MAX
      time_series_data = Historical.quote(symbol, period).map do |quote|
        max = quote.adjClose if max < quote.adjClose
        min = quote.adjClose if min > quote.adjClose
        [Date.parse(quote.date).strftime('%Q').to_i, quote.adjClose]
      end
      {max: max, min: min, time_series_data: time_series_data}
    rescue ArgumentError
      error_handler.call if block_given?
    end
  end
end


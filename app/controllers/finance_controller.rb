require 'stocks'

class FinanceController < ApplicationController
  layout 'finance'

  include Messages
  include Stocks

  before_action :authenticate_user!, only: [:positions]
  around_action :json_only, only: [:historical, :quote]

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

  def details
    @symbol = params[:symbol].upcase
    @quote = YahooFinance::get_extended_quotes(@symbol)[@symbol]
    redirect_to :back if !@quote

    @balance_sheet_url = "https://finance.yahoo.com/q/bs?s=#{@symbol}+Balance+Sheet&annual"
    @cash_flow_url = "https://finance.yahoo.com/q/cf?s=#{@symbol}+Cash+Flow&annual"
    @income_statement_url = "https://finance.yahoo.com/q/is?s=#{@symbol}+Income+Statement&annual"
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

  def portfolio
    @portfolios = Portfolio.where(user_id: current_user.id).order(:name)
  end

  def positions
    redirect_to finance_portfolio_path
  end

  def quote
    begin
      render json: Stocks.quote(params[:symbol])
    rescue Stocks::RetrievalError => e
      render status: 400, json: e.message
    end
  end

  def sizing
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


require 'epsilon'
require 'stocks'

class FinanceController < ApplicationController
  layout 'finance'

  include Stocks

  before_action :authenticate_user!, only: [:charts, :details]

  around_action :json_only, only: [:historical, :quote]

  def charts
    @period = params[:period] || DEFAULT_PERIOD
    @periods = Historical::PERIODS
    @symbol = params[:symbol].upcase

    historical_data = get_historical_data(@symbol, @period) do
      logger.error $!.message
      flash[:alert] = $!.message
      return nil
    end
    if !historical_data.nil?
      gon.max = historical_data[:max]
      gon.min = historical_data[:min]
      gon.time_series_data = historical_data[:time_series_data]
      gon.symbol = @symbol
      gon.period = @period
    end
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

  def quote
    symbol = params[:symbol].upcase
    quote = Quote.get(symbol)[symbol]
    head 400 and return if !quote.valid?
    render json: quote
  end

  def sizing
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


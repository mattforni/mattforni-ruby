require 'stocks'

include ApplicationController::Messages

class FinanceController < ApplicationController
  include Stocks

  def chart
    @periods = Historical::PERIODS
    @symbol = params[:symbol].upcase
    gon.symbol = @symbol
    gon.period = params[:period] || DEFAULT_PERIOD
    begin
      gon.series = Historical.quote(gon.symbol, gon.period).map do |quote|
        [Date.parse(quote.date).strftime('%Q').to_i, quote.adjClose]
      end
    rescue ArgumentError
      logger.error $!.message
      flash[:alert] = $!.message
      redirect_to historical_path gon.symbol
    end
  end

  def historical
    begin
      @quotes = Historical.quote(params[:symbol], params[:period]).map do |quote|
        [Date.parse(quote.date).strftime('%Q').to_i, quote.adjClose]
      end
      respond_to do |format|
        format.html { render status: 200 }
        format.json { render json: @quotes }
      end
    rescue ArgumentError
      logger.error $!.message
      flash[:alert] = $!.message
      redirect_to historical_path params[:symbol]
    end
  end

  def last_trade
    json_only do
      begin
        render json: Stocks.last_trade(params[:symbol])
      rescue Stocks::RetrievalError
        head 400
      end
    end
  end

  def sizing
  end

  def update_stocks
    json_only do
      # Render a 401 and return if an invalid token is provided
      render json: {}, status: 401 and return if params[:token].nil? or params[:token] != 'f0rnac0pia'
      # Else attempt to update last trade if necessary
      updated = []
      stocks = Stock.all
      stocks.each do |stock|
        if stock.update?
          stock.save!
          updated << stock
        end
      end
      render json: {
        evaluated: stocks.size,
        updated: {number: updated.size, records: updated}
      }
    end
  end

  protected

  def attempt_create!(record, success_redirect, failure_redirect)
    begin
      record.create!
      flash[:notice] = success_on_create(record)
      redirect_to success_redirect and return
    rescue ActiveRecord::RecordInvalid
      error_message = error_on_create($!.record)
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
      flash[:notice] = success_on_destroy(record)
      redirect_to success_redirect and return
    rescue ActiveRecord::RecordInvalid
      error_message = error_on_destroy($!.record)
      logger.error "#{error_message} - #{$!.record.errors.full_messages.join(', ')}"
      flash[:alert] = error_message
      flash[:errors] = $!.record.errors.full_messages
      redirect_to failure_redirect and return
    end
  end

  def attempt_update!(record, success_redirect, failure_redirect)
    begin
      record.save!
      flash[:notice] = success_on_update(record)
      redirect_to success_redirect and return
    rescue ActiveRecord::RecordInvalid
      error_message = error_on_update($!.record)
      logger.error "#{error_message} - #{$!.record.errors.full_messages.join(', ')}"
      flash[:alert] = error_message
      flash[:errors] = $!.record.errors.full_messages
      redirect_to failure_redirect and return
    end
  end

  private

  DEFAULT_PERIOD = 'six_months'
end


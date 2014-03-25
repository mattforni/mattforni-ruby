require 'stocks'
include Stocks

# TODO test all methods except index
module Finance
  class StopsController < ApplicationController
    before_action :find_stop, only: [:destroy, :edit, :show, :update]

    def analyze
      respond_to do |format|
        # Only accept json requests
        format.json do
          # Render a 401 and return if an invalid token is provided
          render json: {}, status: 401 and return if params[:token].nil? or params[:token] != 'f0rnuc0pia'
          # Else evaluate all stops and update stop price if necessary
          stopped_out = []
          stop_updated = []
          stops = Stop.all
          stops.each do |stop|
            # If last trade has not changed no need to evaluate
            if stop.update_last_trade?
              stop_updated << stop if stop.update_stop_price?
              stop.save!
              stopped_out << stop if stop.stopped_out?
            end
          end
          StopMailer.stopped_out(stopped_out).deliver if !stopped_out.empty?
          render json: {
            evaluated: stops.size,
            stop_updated: {number: stop_updated.size, records: stop_updated},
            stopped_out: {number: stopped_out.size, records: stopped_out}}
        end
      end
    end

    def create
      @stop = Stop.new(stop_params)
      @stop.symbol.upcase!
      @stop.update?
      @stop.save!
      redirect_to finance_stops_path
    end

    def destroy
    end

    def edit
    end

    def index
      @stops = Stop.all.order(:symbol)
    end

    def new
      @stop = Stop.new
    end

    def show
    end

    def update
    end

    private

    def find_stop
      @stop = Stop.find(params[:id])
    end

    def stop_params
      params.require(:stop).permit(
        :percentage,
        :quantity,
        :stop_price,
        :symbol)
    end
  end
end


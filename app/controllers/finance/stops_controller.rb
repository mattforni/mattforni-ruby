require 'stocks'
include Stocks

# TODO test all methods except index
module Finance
  class StopsController < ApplicationController
    before_action :find_stop, only: [:destroy, :edit, :show, :update]

    def create
      @stop = Stop.new(stop_params)
      @stop.symbol.upcase!
      @stop.save! if @stop.update_stop_price?
      redirect_to finance_stops_path
    end

    def destroy
    end

    def edit
    end

    def index
      @stops = Stop.all
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


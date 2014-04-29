require 'stocks'
include Stocks

# TODO Test all methods except index
class Finance::StopsController < FinanceController
  before_action :authenticate_user!, except: [:analyze]
  before_action :find_stop, only: [:destroy, :edit, :show, :update]

  def analyze
    respond_to do |format|
      # Only accept json requests
      format.json do
        # Render a 401 and return if an invalid token is provided
        render json: {}, status: 401 and return if params[:token].nil? or params[:token] != 'f0rnac0pia'
        # Else evaluate all stops and update stop price if necessary
        stopped_out = []
        updated = []
        # TODO update to authenticate_user and use Stop.by_user
        stops = Stop.all
        stops.each do |stop|
          updated << stop if stop.update?
          stop.save!
          stopped_out << stop if stop.stopped_out?
        end
        StopMailer.stopped_out(stopped_out).deliver if !stopped_out.empty?
        render json: {
          evaluated: stops.size,
          updated: {number: updated.size, records: updated},
          stopped_out: {number: stopped_out.size, records: stopped_out}
        }
      end
    end
  end

  def create
    # Create the new stop model from params
    params[:stop][:symbol].upcase!
    stop = Stop.new(stop_params)
    stop.user = current_user
    begin
      stop.create!
      flash[:notice] = "Successfully created stop for #{stop.symbol}"
      redirect_to finance_stops_path and return
    rescue ActiveRecord::RecordInvalid
      error_msg = "Unable to create #{$!.record.class.to_s.downcase}"
      error_msg += " for #{stop.symbol}" if !(stop.symbol.nil? or stop.symbol.empty?)
      logger.error "#{error_msg}: #{$!.record.errors.full_messages.join(', ')}"
      flash[:alert] = "#{error_msg}."
      flash[:errors] = $!.record.errors.full_messages
      redirect_to new_finance_stop_path and return
    end
  end

  def destroy
  end

  def edit
  end

  def index
    @stops = current_user.stops.order(:symbol)
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
      :symbol
    )
  end
end


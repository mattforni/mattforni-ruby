require 'stocks'
include Stocks

# TODO Test all methods except index
class Finance::HoldingsController < FinanceController
  before_action :authenticate_user!
  before_action :find_holding, only: [:destroy, :edit, :show, :update]

  def create
    # Create the new holding model from params
    params[:holding][:symbol].upcase!
    holding = Holding.new(holding_params)
    holding.user = current_user
    begin
      holding.create!
      flash[:notice] = "Successfully created Holding: #{holding.symbol}"
      redirect_to finance_holdings_path and return
    rescue ActiveRecord::RecordInvalid
      error_msg = "Unable to create #{$!.record.class}"
      logger.error "#{error_msg}: #{$!.record.errors.full_messages.join(', ')}"
      flash[:alert] = error_msg
      flash[:errors] = $!.record.errors.full_messages
      redirect_to new_finance_holding_path and return
    end
  end

  def destroy
  end

  def edit
  end

  def index
    @holdings = current_user.holdings.order(:symbol)
  end

  def new
    @holding = Holding.new
  end

  def show
  end

  def update
  end

  private

  def find_holding
    @holding = Holding.find(params[:id])
  end

  def holding_params
    params.require(:holding).permit(
      :commission_price,
      :purchase_date,
      :purchase_price,
      :quantity,
      :symbol
    )
  end
end


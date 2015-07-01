# TODO Test create, destroy, index
class Finance::HoldingsController < FinanceController
  before_action :authenticate_user!
  # CanCan does not currently support StrongParameters
  authorize_resource only: [:create]
  load_and_authorize_resource except: [:create]

  def create
    # Create the new holding model from params
    @holding = Holding.new(holding_params)
    @holding.symbol.try(:upcase!)
    @holding.user = current_user
    @holding.portfolio = Portfolio.by_user_and_id(current_user, params[:portfolio_id])
    attempt_create!(@holding, finance_portfolios_path, new_finance_holding_path)
  end

  def destroy
    attempt_destroy!(@holding, finance_portfolios_path, finance_holding_path(@holding.id))
  end

  def new
    @portfolios = Portfolio.where(user: current_user)
  end

  private

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


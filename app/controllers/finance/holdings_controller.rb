# TODO Test create, destroy, index
class Finance::HoldingsController < FinanceController
  before_action :authenticate_user!
  # CanCan does not currently support StrongParameters
  authorize_resource only: :create
  load_and_authorize_resource except: :create

  def create
    # Create the new holding model from params
    @holding = Holding.new(holding_params)
    @holding.symbol.try(:upcase!)
    @holding.user = current_user
    @holding.creation_portfolio = Portfolio.by_user_and_id(current_user, params[:portfolio_id])
    attempt_create!(@holding, finance_portfolios_path, new_finance_holding_path)
  end

  def destroy
    attempt_destroy!(@holding, finance_portfolios_path, finance_holding_path(@holding))
  end

  def edit
  end

  def new
    @portfolios = current_user.portfolios
  end

  # TODO move to model, add error handling and test
  def update
    holding = holding_params
    update_position = !(Epsilon.equal?(holding[:purchase_price].to_f, @holding.purchase_price) and
        Epsilon.equal?(holding[:quantity].to_f, @holding.quantity))

    @holding.transaction do
      @holding.update(holding)
      
      @holding.position.update! if update_position
    end

    redirect_to finance_portfolios_path
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


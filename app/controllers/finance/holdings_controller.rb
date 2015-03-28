# TODO Test create, index
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
    attempt_create!(@holding, positions_path, new_finance_holding_path)
  end

  # TODO test
  def destroy
    attempt_destroy!(@holding, positions_path, finance_holding_path(@holding.id))
  end

  def edit
  end

  def index
    @holdings.order!(:symbol, :purchase_date)
  end

  def new
  end

  def show
  end

  def update
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


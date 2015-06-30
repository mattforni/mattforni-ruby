# TODO Test all
class Finance::PositionsController < FinanceController
  before_action :authenticate_user!
  authorize_resource only: [:edit, :update]
  load_and_authorize_resource

  def edit
    @portfolios = Portfolio.where(user: current_user)
    @position = Position.find(params[:id])
  end

  def update
    @position.portfolio = Portfolio.by_user_and_id(current_user, params[:portfolio_id])
    @position.save!
    redirect_to finance_portfolios_path
  end
end


# TODO Test create
class Finance::PortfoliosController < FinanceController
  before_action :authenticate_user!
  # CanCan does not currently support StrongParameters
  authorize_resource only: [:create]
  load_and_authorize_resource except: [:create]

  def create
    # Create the new portfolio model from params
    @portfolio = Portfolio.new(portfolio_params)
    @portfolio.user = current_user
    attempt_create!(@portfolio, finance_portfolio_path, new_finance_portfolio_path)
  end

  def new
  end

  private

  def portfolio_params
    params.require(:portfolio).permit(:name)
  end
end

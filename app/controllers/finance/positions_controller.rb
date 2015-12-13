# TODO Test all
class Finance::PositionsController < FinanceController
  before_action :authenticate_user!
  authorize_resource only: :edit
  load_and_authorize_resource except: :edit

  def destroy
    attempt_destroy!(@position, finance_portfolios_path, finance_portfolios_path)
  end

  def edit
    @portfolios = Portfolio.where(user: current_user)
    @position = Position.find(params[:id])
  end

  def holdings
    @symbol = @position.symbol
    @quote = Quote.get(@symbol)[@symbol]
    respond_to do |format|
      format.html {
        render layout: false, status: :ok, success: true
      }
    end
  end

  def update
    @position.portfolio = Portfolio.by_user_and_id(current_user, params[:portfolio_id])
    @position.save!
    redirect_to finance_portfolios_path
  end
end


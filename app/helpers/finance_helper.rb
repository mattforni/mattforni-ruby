module FinanceHelper
  def holding_partial(holding, index)
    render partial: 'finance/holdings/holding', locals: {holding: holding, index: index}
  end

  def portfolio_partial(portfolio)
    render partial: 'finance/portfolios/portfolio', locals: {portfolio: portfolio}
  end

  def position_partial(position, index)
    render partial: 'finance/positions/position', locals: {position: position, index: index}
  end

  def positivity_class(value)
    value < 0 ? 'negative' : 'positive'
  end

  def spread_chart_partial(lowest, highest, current)
    offset = (current - lowest) / (highest - lowest) * 100.0 rescue nil
    render partial: 'finance/charts/spread', locals: {lowest: lowest, highest: highest, offset: offset}
  end
end


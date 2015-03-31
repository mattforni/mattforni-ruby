module FinanceHelper
  def holding_partial(holding, index)
    render partial: 'finance/holdings/holding', locals: {holding: holding, index: index}
  end

  def position_partial(position, index)
    render partial: 'finance/positions/position', locals: {position: position, index: index}
  end

  def spread_chart_partial(lowest, highest)
    render partial: 'finance/charts/spread', locals: {lowest: lowest, highest: highest}
  end
end


module FinanceHelper
  def holding_partial(index, holding, quote)
    render partial: 'finance/holdings/holding', locals: {index: index, holding: holding, quote: quote}
  end

  def percentage_class(value)
    return '' if value.nil? or value == 0
    return 'green' if value > 0 && value < 5
    return 'yellow' if value >= 5 && value < 15
    return 'red' if value >= 15
    value < 0 ? 'negative' : 'positive'
  end

  def portfolio_partial(portfolio, quotes)
    render partial: 'finance/portfolios/portfolio', locals: {portfolio: portfolio, quotes: quotes}
  end

  def position_partial(index, position, quote)
    render partial: 'finance/positions/position', locals: {index: index, position: position, quote: quote}
  end

  def positivity_class(value)
    return '' if value.nil? or value == 0
    value < 0 ? 'negative' : 'positive'
  end

  def spread_chart_partial(lowest, highest, current)
    offset = (current - lowest) / (highest - lowest) * 100.0 rescue nil
    render partial: 'finance/charts/spread', locals: {lowest: lowest, highest: highest, offset: offset}
  end
end


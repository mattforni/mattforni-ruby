require 'ranges'

include Ranges

module FinanceHelper
  def holding_partial(index, holding, quote, visible = false)
    render partial: 'finance/holdings/holding', locals: {index: index, holding: holding, quote: quote, visible: visible}
  end

  def percentage_class(value)
    return '' if value.nil? or value == 0
    return 'green' if PERCENTAGE[:ok].include? value
    return 'yellow' if PERCENTAGE[:warn].include? value
    return 'red' if PERCENTAGE[:error].include? value 
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


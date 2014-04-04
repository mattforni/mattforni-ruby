module ApplicationHelper
  NA = "N/A"

  def alt_display(value, alternative = NA)
    return value.nil? ? alternative : value
  end

  def price_class(value)
    return value > 0 ? 'positive' : 'negative'
  end
end


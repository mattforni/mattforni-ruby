module ApplicationHelper
  NA = "N/A"

  def alt_display(value, alternative = NA)
    return value.nil? ? alternative : value
  end

  def currency_display(currency)
    number_to_currency(currency, delimiter: ',', precision: 3)
  end

  def date_display(time)
    time.strftime("%^b %d %Y")
  end

  def decimal_display(decimal)
    number_with_precision(decimal, delimiter: ',', precision: 3)
  end

  def time_display(time)
    time.strftime("%^b %d %Y %H:%M")
  end

  def price_class(value)
    return value > 0 ? 'positive' : (value == 0 ? '' : 'negative')
  end
end


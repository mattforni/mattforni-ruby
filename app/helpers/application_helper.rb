module ApplicationHelper
  NA = "N/A"

  def add_link(path, conditions = true)
    link_to '+', path if conditions
  end

  def alt_display(value, alternative = NA)
    return value.nil? ? alternative : value
  end

  def currency_display(currency)
    number_to_currency(currency, delimiter: ',', precision: 2)
  end

  def date_display(time)
    time.strftime("%^b %d %Y")
  end

  def decimal_display(decimal, precision = 3)
    number_with_precision(decimal, delimiter: ',', precision: precision)
  end

  def price_class(value)
    return value > 0 ? 'positive' : (value == 0 ? '' : 'negative')
  end

  def time_display(time)
    time.strftime("%^b %d %Y %H:%M")
  end

  def external_image(name, link)
    render partial: 'external/logo', locals: {name: name, link: link}
  end
end


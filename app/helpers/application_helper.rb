module ApplicationHelper
  NA = "N/A"

  def add_link(path, conditions = true)
    link_to '+', path if conditions
  end

  def alt_display(value, alternative = NA)
    return value.nil? ? alternative : value
  end

  def asset_exists?(filename, extension)
    return false if filename.nil? or filename.empty? or extension.nil? or extension.empty?
    !Mattforni::Application.assets.find_asset("#{filename}.#{extension}").nil?
  end

  def currency_display(currency)
    number_to_currency(currency, delimiter: ',', precision: 2, negative_format: '-%u%n')
  end

  def date_display(time)
    time.strftime("%^b %d %Y")
  end

  def decimal_display(decimal, precision = 3)
    number_with_precision(decimal, delimiter: ',', precision: precision)
  end

  def destroy_button(target, condition = true)
    button_to ' ', target, data: {confirm: 'You sure?'}, method: :delete, class: 'destroy', form_class: 'destroy' if condition
  end

  def edit_link(target, condition = true)
    link_to image_tag('icons/edit.png', size: '13x13'), target, class: 'edit' if condition
  end

  def external_image(name, link)
    render partial: 'external/logo', locals: {name: name, link: link}
  end

  def percentage_display(percentage, precision = 1)
    "#{number_with_precision(percentage, precision: precision)}%"
  end

  def price_class(value)
    return value > 0 ? 'positive' : (value == 0 ? '' : 'negative')
  end

  # TODO this is not actually safe, ie. surprise! & surprise@ both eval to 'surprise-'
  def safe_str(string)
    string.gsub(/[\(\)\!\{\}\[\]\!\?\@\#\$\%\^\&\*]/, '-')
  end

  def time_display(time)
    time.strftime("%^b %d %Y %H:%M")
  end
end


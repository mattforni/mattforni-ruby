module ApplicationHelper
  NA = "N/A"

  def alt_display(value, alternative = NA)
    return value.nil? ? alternative : value
  end
end


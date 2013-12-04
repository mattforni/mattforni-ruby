module ApplicationHelper
  def stylesheet_exist?(path)
    File.exist?("#{File.join('public', 'stylesheets', path)}.css")
  end
  
  def view_image_exist?(view, filename)
    File.exist?(File.join('public', 'images', view, filename))
  end
  
  def get_view_image(view, filename)
    File.join(view, filename)
  end
end


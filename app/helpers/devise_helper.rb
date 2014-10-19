module DeviseHelper
  def devise_error_messages!
    return false if !defined? resource or resource.nil? or resource.errors.empty?
    flash.now[:errors] ||= []
    flash.now[:alert] = 'Unable to register user.'
    resource.errors.each do |key, value|
      message = "#{key} #{value}".capitalize
      flash.now[:errors] << message if !flash.now[:errors].include? message
    end
    true
  end
end


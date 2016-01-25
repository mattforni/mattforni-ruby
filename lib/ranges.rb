module Ranges
  COMMISSION_RANGE = {greater_than_or_equal_to: 0}
  PERCENTAGE_RANGE =  {greater_than: 0, less_than: 100}
  PRICE_RANGE = {greater_than: 0}
  QUANTITY_RANGE = {greater_than: 0}

  PERCENTAGE = {
    ok: 0...5,
    warn: 5...15,
    error: 15..100
  }

  class AlertValidator < ActiveModel::Validator
    def validate(model)
      # :greater_than or :less_than must be provided
      raise ArgumentError.new MISSING_PARAMS_MESSAGE if model.greater_than.nil? and model.less_than.nil?

      # if :greater_than and less than have been provided
      if !(model.greater_than.nil? or model.less_than.nil?)
        raise ArgumentError.new RANGE_ERROR_MESSAGE if model.greater_than >= model.less_than 
      end
    end

    private

    MISSING_PARAMS_MESSAGE = 'Must provide a value for either the upper or lower bound of the alert.'
    RANGE_ERROR_MESSAGE = 'The upper bound of the alert must be strictly greater than the lower bound.'
  end
end


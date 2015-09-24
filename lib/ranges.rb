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
end


FactoryGirl.define do
  factory :holding do
    commission_price 5
    highest_price 20
    highest_time Time.now
    lowest_price 10
    lowest_time Time.now
    position
    purchase_date Date.today
    purchase_price 15
    quantity 100
    symbol { position.stock.symbol }
    user
  end

  factory :portfolio do
    sequence(:name) { |n| "#{Portfolio::DEFAULT_NAME}-#{n}" }
    user
  end

  factory :position do
    commission_price 5
    portfolio
    purchase_price 15
    quantity 100
    stock
    symbol { stock.symbol }
    user
  end

  factory :stock do
    highest_price 25
    highest_time Time.now.utc
    last_trade 10
    sequence(:symbol) { |n| "SYM#{n}" }
    lowest_price 5
    lowest_time Time.now.utc
    updated_at Time.now.utc - 5.minutes
  end

  factory :stop do
    highest_price 40
    highest_time Time.now.utc
    percentage 5
    position
    stop_price 20
    symbol { position.stock.symbol }
    lowest_price 5
    lowest_time Time.now.utc
  end

  factory :user do
    sequence(:email) { |n| "user#{n}@mattforni.com" }
    password '12345678'
    encrypted_password { password }
  end
end



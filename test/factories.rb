FactoryGirl.define do
  factory :holding do
    commission_price 5
    position
    purchase_date Date.today
    purchase_price 15
    quantity 100
    symbol { position.stock.symbol } 
    user
  end

  factory :position do
    commission_price 5
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
    symbol 'ABC'
    lowest_price 5
    lowest_time Time.now.utc
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


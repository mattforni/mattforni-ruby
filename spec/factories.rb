FactoryGirl.define do
  factory :alert do
    active true
    greater_than 1.234
    less_than 5.768
    name 'alert'
    stock
    user
  end

  factory :blog_post do
    content 'this is the content'
    description 'described by this'
    short_url 'blog_post'
    title 'this is a blog post'
  end

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
    user { portfolio.user }
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
    lowest_price 5
    lowest_time Time.now.utc
    percentage 25
    position
    stop_price { position.stock.last_trade * (1 - (percentage.to_f / 100.to_f)) }
    symbol { position.stock.symbol }
    user { position.user }
  end

  factory :user do
    sequence(:email) { |n| "user#{n}@mattforni.com" }
    password '12345678'
    encrypted_password { password }
  end
end



class AddHighestLowestToHoldings < ActiveRecord::Migration
  def change
    add_column :holdings, :highest_price, :decimal, precision: 15, scale: 5
    add_column :holdings, :highest_time, :timestamp
    add_column :holdings, :lowest_price, :decimal, precision: 15, scale: 5
    add_column :holdings, :lowest_time, :timestamp

    stocks = Stock.all
    stocks.each do |stock|
      stock.save! if stock.update?(true)
    end

    change_column :holdings, :highest_price, :decimal, null: false, precision: 15, scale: 5
    change_column :holdings, :highest_time, :timestamp, null: false
    change_column :holdings, :lowest_price, :decimal, null: false, precision: 15, scale: 5
    change_column :holdings, :lowest_time, :timestamp
  end
end


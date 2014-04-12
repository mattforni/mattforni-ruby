class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :symbol, null: false, limit: 10
      t.string :name
      t.decimal :previous_close, precision: 15, scale: 5
      t.decimal :last_trade, null: false, precision: 15, scale: 5
      t.decimal :lowest_price, null: false, precision: 15, scale: 5
      t.timestamp :lowest_time, null: false
      t.decimal :highest_price, null: false, precision: 15, scale: 5
      t.timestamp :highest_time, null: false

      t.timestamps
    end
    add_index :stocks, :symbol, name: 'stock_by_symbol_index', unique: true
  end
end


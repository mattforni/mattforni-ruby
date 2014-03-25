class CreateStops < ActiveRecord::Migration
  def change
    create_table :stops do |t|
      t.string :symbol, null: false, limit: 10, unique: true
      t.decimal :percentage, null: false, precision: 15, scale: 5
      t.decimal :last_trade, null: false, precision: 15, scale: 5
      t.decimal :stop_price, null: false, precision: 15, scale: 5
      t.decimal :quantity, precision: 15, scale: 3
      t.decimal :pinnacle_price, precision: 15, scale: 5
      t.datetime :pinnacle_date

      t.timestamps
    end
  end
end


class CreatePositions < ActiveRecord::Migration
  def up
    create_table :positions do |t|
      t.string :symbol, null: false, limit: 10
      t.decimal :quantity, precision: 15, scale: 3, null: false
      t.decimal :purchase_price, null: false, precision: 15, scale: 5
      t.decimal :commission_price, null: false, default: 0, precision: 15, scale: 5
      t.references :user, null: false
      t.references :stock, null: false

      t.timestamps
    end
    add_index :positions, :user_id, name: 'position_by_user_index'
    add_index :positions, :stock_id, name: 'position_by_stock_index'

    # Create a new Stock and Position model for each Stop
    add_column :stops, :position_id, :integer
    add_column :stops, :lowest_price, :decimal, precision: 15, scale: 5
    add_column :stops, :lowest_time, :timestamp
    Stop.all.each do |stop|
      stock = Stock.new({
        symbol: stop.symbol,
        last_trade: stop.last_trade.nil? ? 0.00001 : stop.last_trade,
        lowest_price: stop.pinnacle_price.nil? ? 10000 : stop.pinnacle_price,
        lowest_time: stop.pinnacle_date.nil? ? Time.now.utc : stop.pinnacle_date,
        highest_price: stop.pinnacle_price.nil? ? 0.00001 : stop.pinnacle_price,
        highest_time: stop.pinnacle_date.nil? ? Time.now.utc : stop.pinnacle_date
      })
      stock.save!
      position = Position.new({
        symbol: stop.symbol,
        quantity: stop.quantity.nil? ? 1 : stop.quantity,
        purchase_price: 1,
        stock_id: stock.id,
        user_id: stop.user.id
      })
      position.save!
      stop.position_id = position.id
      stop.pinnacle_price = 0.00001 if stop.pinnacle_price.nil?
      stop.pinnacle_date = Date.today if stop.pinnacle_date.nil?
      stop.lowest_price = stop.pinnacle_price
      stop.lowest_time = stop.pinnacle_date
      stop.save!
    end
    change_column :stops, :position_id, :integer, null: false
    rename_column :stops, :pinnacle_date, :highest_time
    change_column :stops, :highest_time, :timestamp, null: false
    rename_column :stops, :pinnacle_price, :highest_price
    change_column :stops, :highest_price, :decimal, null: false
    change_column :stops, :lowest_price, :decimal, null: false, precision: 15, scale: 5
    change_column :stops, :lowest_time, :timestamp, null: false

    # Remove last_trade from Stop to master in Stock model
    remove_column :stops, :last_trade, :decimal
  end

  def down
    # Add last_trade back to Stop
    add_column :stops, :last_trade, :decimal, default: 1, null: false

    # Update Stop model with data from Stock model
    Stop.all.each do |stop|
      position = stop.position 
      stock = stop.position.stock
      stop.last_trade = stock.last_trade
      stop.highest_price = stock.highest_price
      stop.highest_time = stock.highest_time
      stop.save!
    end

    rename_column :stops, :highest_time, :pinnacle_date
    change_column :stops, :pinnacle_date, :date
    rename_column :stops, :highest_price, :pinnacle_price
    remove_column :stops, :lowest_price
    remove_column :stops, :lowest_time

    remove_column :stops, :position_id, :integer
    drop_table :positions
  end
end


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
    add_column :stops, :trough_price, :decimal, precision: 15, scale: 5
    add_column :stops, :trough_time, :timestamp
    Stop.all.each do |stop|
      stock = Stock.new({
        symbol: stop.symbol,
        last_trade: stop.last_trade.nil? ? BigDecimal.new("-Infinity") : stop.last_trade,
        trough_price: stop.pinnacle_price.nil? ? BigDecimal.new("Infinity") : stop.pinnacle_price,
        trough_time: stop.pinnacle_date.nil? ? Time.now.utc : stop.pinnacle_date,
        crest_price: stop.pinnacle_price.nil? ? BigDecimal.new("-Infinity") : stop.pinnacle_price,
        crest_time: stop.pinnacle_date.nil? ? Time.now.utc : stop.pinnacle_date
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
      stop.pinnacle_price = 0.01 if stop.pinnacle_price.nil?
      stop.pinnacle_date = Date.today if stop.pinnacle_date.nil?
      stop.trough_price = stop.pinnacle_price
      stop.trough_time = stop.pinnacle_date
      stop.save!
    end
    change_column :stops, :position_id, :integer, null: false
    rename_column :stops, :pinnacle_date, :crest_time
    change_column :stops, :crest_time, :timestamp, null: false
    rename_column :stops, :pinnacle_price, :crest_price
    change_column :stops, :crest_price, :decimal, null: false
    change_column :stops, :trough_price, :decimal, null: false, precision: 15, scale: 5
    change_column :stops, :trough_time, :timestamp, null: false

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
      stop.crest_price = stock.crest_price
      stop.crest_time = stock.crest_time
      stop.save!
    end

    rename_column :stops, :crest_time, :pinnacle_date
    change_column :stops, :pinnacle_date, :date
    rename_column :stops, :crest_price, :pinnacle_price
    remove_column :stops, :trough_price
    remove_column :stops, :trough_time

    remove_column :stops, :position_id, :integer
    drop_table :positions
  end
end


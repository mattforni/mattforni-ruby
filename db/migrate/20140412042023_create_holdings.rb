class CreateHoldings < ActiveRecord::Migration
  def change
    create_table :holdings do |t|
      t.string :symbol, null: false, limit: 10
      t.decimal :quantity, precision: 15, scale: 3, null: false
      t.decimal :purchase_price, null: false, precision: 15, scale: 5
      t.date :purchase_date, null: false
      t.decimal :commission_price, null: false, default: 0, precision: 15, scale: 5
      t.references :user, null: false
      t.references :position, null: false

      t.timestamps
    end
    add_index :holdings, :user_id, name: 'holding_by_user_index'
    add_index :holdings, :position_id, name: 'holding_by_position_index'
  end
end


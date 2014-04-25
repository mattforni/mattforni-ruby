class AddIndexToHolding < ActiveRecord::Migration
  def change
    add_index :positions, [:user_id, :symbol], name: 'position_by_user_and_symbol_index'
    add_index :holdings, [:user_id, :symbol], name: 'holding_by_user_and_symbol_index'
  end
end


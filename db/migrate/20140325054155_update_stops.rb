class UpdateStops < ActiveRecord::Migration
  def change
    change_column :stops, :pinnacle_date, :date
  end
end


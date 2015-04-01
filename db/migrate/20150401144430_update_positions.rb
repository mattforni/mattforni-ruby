class UpdatePositions < ActiveRecord::Migration
  def up
    Position.all.each { |position| position.update! }
  end
end

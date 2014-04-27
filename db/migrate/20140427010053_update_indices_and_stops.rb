class UpdateIndicesAndStops < ActiveRecord::Migration
  def change
    Stop.all.each do |s|
      if (s.position.nil?)
        position = Position.by_user_and_symbol(s.user, s.symbol)
        raise "Could not find position for #{s.symbol}" if position.nil?
        s.position = position
        s.save!
      end
    end
  end
end

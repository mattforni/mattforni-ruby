class AddUsersToStops < ActiveRecord::Migration
  def change
    add_column :stops, :user_id, :integer
    if !Rails.env.development?
      execute <<-SQL
        ALTER TABLE stops 
          ADD CONSTRAINT fk_stops_users
          FOREIGN KEY (user_id)
          REFERENCES users(id)
      SQL
    end
    stops = Stop.all
    if !stops.empty?
      user = User.where(email: 'mattforni@gmail.com').first
      raise 'No user with email \'mattforni@gmail.com\'' if user.nil?
      Stop.all.each do |stop|
        stop.user_id = user.id
        stop.save!
      end
    end
    change_column :stops, :user_id, :integer, null: false
  end
end


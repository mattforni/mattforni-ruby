class AddUsersToStops < ActiveRecord::Migration
  def change
    user = User.where(email: 'mattforni@gmail.com').first
    raise 'No user with email \'mattforni@gmail.com\'' if user.nil?
    add_column :stops, :user_id, :integer
    if !Rails.env.development?
      execute <<-SQL
        ALTER TABLE stops 
          ADD CONSTRAINT fk_stops_users
          FOREIGN KEY (user_id)
          REFERENCES users(id)
      SQL
    end
    Stop.all.each do |stop|
      stop.user_id = user.id
      stop.save!
    end
    change_column :stops, :user_id, :integer, null: false
  end
end


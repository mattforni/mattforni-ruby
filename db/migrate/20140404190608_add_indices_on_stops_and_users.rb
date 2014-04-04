class AddIndicesOnStopsAndUsers < ActiveRecord::Migration
  def change
    add_index :stops, :user_id, name: 'by_user'
    add_index :users, :email, name: 'by_email'
  end
end

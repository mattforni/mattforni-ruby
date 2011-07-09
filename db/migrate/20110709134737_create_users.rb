class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :alias, :limit => 80, :null => false
      t.text :password, :null => false
      t.string :role, :limit=> 50, :null => false
      t.string :email
      t.timestamps
    end   
  end

  def self.down
    drop_table :users
  end
end

class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.boolean :active, nil: false, default: true
      t.decimal :greater_than, default: nil
      t.decimal :less_than, default: nil
      t.string :name, default: nil
      t.references :stock, null: false
      t.datetime :triggered_at, default: nil
      t.references :user, null: false
    end
  end
end


class CreatePortfolios < ActiveRecord::Migration
  def up
    # Create the new 'portfolios' table
    create_table :portfolios do |t|
      t.string :name, null: false
      t.references :user, null: false

      t.timestamps
    end
    add_index :portfolios, [:user_id, :name], name: 'portfolio_by_user_and_name_index', unique: true

    # Add the portfolio foreign key to positions
    add_column :positions, :portfolio_id, :integer
    if Rails.env.production?
      execute <<-SQL
        ALTER TABLE positions
          ADD CONSTRAINT fk_positions_portfolios
          FOREIGN KEY (portfolio_id)
          REFERENCES portfolios(id)
      SQL
    end

    # For each user, create a default portfolio
    User.all.each do |user|
      Portfolio.transaction do
        # Create a new portfolio
        portfolio = Portfolio.new({user: user, name: Portfolio::DEFAULT_NAME})
        portfolio.save!

        # Update each of the user's positions
        user.positions.each do |position|
          position.portfolio = portfolio
          position.save!
        end
      end
    end

    # Now that all positions have an associated portfolio, make the field non-nullable
    change_column :positions, :portfolio_id, :integer, null: false
  end

  def down
    remove_column :positions, :portfolio_id

    drop_table :portfolios
  end
end


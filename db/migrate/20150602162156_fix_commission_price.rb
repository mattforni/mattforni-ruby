class FixCommissionPrice < ActiveRecord::Migration
  def change
    Position.all.each do |position|
      position.commission_price = position.holdings.reduce(0) do |sum, holding|
        sum += holding.commission_price
      end
    end
  end
end

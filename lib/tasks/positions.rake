desc 'Tasks pretaining to positions'

task :update_positions => :environment do
  Position.all.each do |position|
    position.update!
    puts "Updated '#{position.symbol}'\tposition for #{position.user.email}"
  end
end


module Finance
	class StopsController < ApplicationController
		before_action :find_stop, except: [:create, :index, :new]

		def create
			@stop = Stop.new(stop_params)
			@stop.symbol.upcase!
			@stop.save!
		end

		def destroy
		end

		def edit
		end

		def index 
			@stops = Stop.all
		end

		def new
			@stop = Stop.new
		end

		def show
		end

		def update
		end

		private

		def find_stop
			@stop = Stop.find(params[:id])
		end

		def stop_params
			params.require(:stop).permit(
				:percentage,
				:pinnacle_date,
				:pinnacle_price,
				:quantity, 
				:stop_price,
				:symbol)
		end
	end
end


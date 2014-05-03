require 'spec_helper'

describe Finance::StopsController do
  login
  $symbol = 'ABC'

  describe 'GET index' do
    context 'when there are no stops' do
      it 'renders no stops' do
        get :index

        expect(response.status).to eq(200)
        expect(assigns(:stops)).to be_empty
        expect(response).to render_template('layouts/application')
        expect(response).to render_template(:index)
      end
    end

    context 'when there is at least one stop' do
      it 'renders stops' do
        create(:stop, user: @user)
        get :index

        expect(response.status).to eq(200)
        stops = assigns(:stops)
        expect(stops).to_not be_empty
        expect(stops.size).to eq(1)
        expect(response).to render_template('layouts/application')
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET edit' do
    context 'when id does not exist' do
      it 'redirects to root_url' do
        get :edit, {id: 123}

        expect(flash[:alert]).to_not be_nil
        expect(response).to redirect_to root_url
      end
    end

    it 'renders the edit page' do
      stop = create(:stop, user: @user)
      get :edit, {id: stop.id}

      expect(response.status).to eq(200)
      got = assigns(:stop)
      expect(got).to eq(stop)
      expect(response).to render_template('layouts/application')
      expect(response).to render_template(:edit)
    end
  end

  describe 'GET new' do
    it 'renders the new page' do
      get :new

      expect(response.status).to eq(200)
      expect(response).to render_template('layouts/application')
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    context 'when symbol is nil' do
      it 'fails post creation and redirects to new stop path' do
        post :create, {stop: {percentage: 0}}

        expect(flash[:alert]).to_not be_nil
        expect(flash[:alert]).to eq(error_on_create(build(:stop, symbol: '')))
        expect(flash[:errors]).to_not be_empty
        expect(flash[:errors]).to include('Position could not be found')
        expect(response).to redirect_to new_finance_stop_path
      end
    end

    context 'when percentage is nil' do
      it 'fails post creation and redirects to new stop path' do
        create(:position, {symbol: $symbol, user: @user})
        post :create, {stop: {symbol: $symbol}}

        expect(flash[:alert]).to_not be_nil
        expect(flash[:alert]).to eq(error_on_create(Stop.new({symbol: $symbol})))
        expect(flash[:errors]).to_not be_empty
        expect(flash[:errors]).to include('Percentage cannot be nil')
        expect(response).to redirect_to new_finance_stop_path
      end
    end

    context 'when percentage is <= 0' do
      it 'fails post creation and redirects to new stop path' do
        create(:position, {symbol: $symbol, user: @user})
        post :create, {stop: {symbol: $symbol, percentage: 0}}

        expect(flash[:alert]).to_not be_nil
        expect(flash[:alert]).to eq(error_on_create(Stop.new({symbol: $symbol})))
        expect(flash[:errors]).to_not be_empty
        expect(flash[:errors]).to include('Percentage must be greater than 0')
        expect(response).to redirect_to new_finance_stop_path
      end
    end

    context 'when percentage is >= 100' do
      it 'fails post creation and redirects to new stop path' do
        create(:position, {symbol: $symbol, user: @user})
        post :create, {stop: {symbol: $symbol, percentage: 100}}

        expect(flash[:alert]).to_not be_nil
        expect(flash[:alert]).to eq(error_on_create(Stop.new({symbol: $symbol})))
        expect(flash[:errors]).to_not be_empty
        expect(flash[:errors]).to include('Percentage must be less than 100')
        expect(response).to redirect_to new_finance_stop_path
      end
    end

    context 'when position does not exist' do
      it 'fails post creation and redirects to new stop path' do
        post :create, {stop: {symbol: $symbol, percentage: 25}}

        expect(flash[:alert]).to_not be_nil
        expect(flash[:alert]).to eq(error_on_create(build(:stop, symbol: $symbol)))
        expect(flash[:errors]).to_not be_empty
        expect(flash[:errors]).to include('Position could not be found')
        expect(response).to redirect_to new_finance_stop_path
      end
    end

    it 'creates a stop and redirects to finance stops path' do
      create(:position, {symbol: $symbol, user: @user})
      Stop.by_user_and_symbol(@user, $symbol).should be_empty

      post :create, {stop: {symbol: $symbol, percentage: 25}}
      stops = Stop.by_user_and_symbol(@user, $symbol)

      expect(stops).to_not be_empty
      expect(stops.size).to eq(1)
      expect(flash[:alert]).to be_nil
      expect(flash[:notice]).to_not be_nil
      expect(flash[:notice]).to eq(success_on_create(stops.first))
      expect(response).to redirect_to finance_stops_path
    end
  end

  describe 'POST update' do
    context 'when percentage is <= 0' do
      it 'fails post update and redirects to edit stop path' do
        stop = create(:stop, {symbol: $symbol, user: @user})
        post :update, {id: stop.id, stop: {percentage: 0}}

        expect(flash[:alert]).to_not be_nil
        expect(flash[:alert]).to eq(error_on_update(stop))
        expect(flash[:errors]).to_not be_empty
        expect(flash[:errors]).to include('Percentage must be greater than 0')
        expect(response).to redirect_to edit_finance_stop_path(stop.id)
      end
    end

    context 'when percentage is >= 100' do
      it 'fails post update and redirects to edit stop path' do
        stop = create(:stop, {symbol: $symbol, user: @user})
        post :update, {id: stop.id, stop: {percentage: 100}}

        expect(flash[:alert]).to_not be_nil
        expect(flash[:alert]).to eq(error_on_update(stop))
        expect(flash[:errors]).to_not be_empty
        expect(flash[:errors]).to include('Percentage must be less than 100')
        expect(response).to redirect_to edit_finance_stop_path(stop.id)
      end
    end

    it 'updates the stop' do
      stop = create(:stop, {symbol: $symbol, user: @user})
      post :update, {id: stop.id, stop: {percentage: 10}}

      expect(flash[:alert]).to be_nil
      expect(flash[:notice]).to_not be_nil
      expect(flash[:notice]).to eq(success_on_update(stop))
      expect(response).to redirect_to finance_stops_path
    end
  end
end


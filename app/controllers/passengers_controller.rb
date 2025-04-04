class PassengersController < ApplicationController
  # POST /passengers
  def create
    passenger = Passenger.new(passenger_params)
    if passenger.save
      render json: passenger, status: :created
    else
      render json: passenger.errors, status: :unprocessable_entity
    end
  end

  # GET /passengers/:id
  def show
    passenger = Passenger.find(params[:id])
    render json: passenger
  end

  # PUT /passengers/:id
  def update
    passenger = Passenger.find(params[:id])
    if passenger.update(passenger_params)
      render json: passenger
    else
      render json: passenger.errors, status: :unprocessable_entity
    end
  end

  # DELETE /passengers/:id
  def destroy
    passenger = Passenger.find(params[:id])
    passenger.destroy
    render json: { message: 'Passenger deleted successfully' }
  end

  private

  def passenger_params
    params.require(:passenger).permit(:name, :email, :password, :password_confirmation)
  end
end

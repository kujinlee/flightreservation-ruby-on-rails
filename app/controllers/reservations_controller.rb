class ReservationsController < ApplicationController
  # GET /reserve
  def render_reservation_page
    @flight = Flight.find(params[:flight_id])
    render 'reservations/reserve'
  end

  # POST /createReservation
  def create_reservation
    passenger = Passenger.find_or_create_by(email: params[:email]) do |p|
      p.first_name = params[:first_name]
      p.last_name = params[:last_name]
      p.phone = params[:phone]
    end

    @reservation = Reservation.new(
      passenger_id: passenger.id,
      flight_id: params[:flight_id],
      card_number: params[:card_number],
      amount: params[:amount],
      status: 'PENDING' # Ensure status is set to a valid default value
    )

    if @reservation.save
      @flight = @reservation.flight
      @passenger = passenger
      render 'reservations/reservation_confirmation'
    else
      render json: @reservation.errors, status: :unprocessable_entity
    end
  end

  # POST /completeReservation
  def complete_reservation
    @reservation = Reservation.find(params[:reservation_id])
    @flight = @reservation.flight
    @passenger = @reservation.passenger

    # Mock payment processing logic
    payment_successful = mock_payment_process(@reservation.amount)

    if payment_successful
      @reservation.update(status: 'CONFIRMED')
      render 'reservations/complete_reservation', locals: { success: true }
    else
      render 'reservations/complete_reservation', locals: { success: false }
    end
  end

  private

  def mock_payment_process(amount)
    # Placeholder for external payment processing logic
    # Always returns true for now
    true
  end
end

class CheckInsController < ApplicationController
  def create
    reservation = Reservation.find(params[:reservation_id])
    reservation.update(number_of_bags: params[:number_of_bags], checked_in: true)
    @reservation = reservation
    render 'reservations/check_in_confirmation'
  end

  def render_check_in_page
    @reservation = Reservation.find(params[:reservation_id])
    @passenger = @reservation.passenger
    @flight = @reservation.flight
    render 'reservations/check_in', formats: [:html]
  end
end
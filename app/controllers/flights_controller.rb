class FlightsController < ApplicationController
  # GET /findFlights
  def render_find_flights
    # Render the find flights form
    render 'flights/find_flights', formats: [:html]
  end

  # POST /findFlights
  def find_flights
    @flights = Flight.search_flights(params[:departure_city], params[:arrival_city], params[:date_of_departure])
    render 'flights/find_flights_results', formats: [:html]
  end
end

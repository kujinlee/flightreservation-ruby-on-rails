Rails.application.routes.draw do
  scope "/#{ENV['BASE_URL']}" do
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check

    # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
    # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
    # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

    # Defines the root path route ("/")
    root "flights#render_find_flights"

    # Custom routes for flights
    get '/findFlights', to: 'flights#render_find_flights', as: :findFlights
    post '/findFlights', to: 'flights#find_flights'
    get '/reserve', to: 'reservations#render_reservation_page', as: :reserve
    post '/createReservation', to: 'reservations#create_reservation', as: :createReservation
    match '/completeReservation', to: 'reservations#complete_reservation', via: [:get, :post], as: :completeReservation
    get '/checkIn', to: 'check_ins#render_check_in_page', as: :checkIn
    post '/completeCheckIn', to: 'check_ins#create', as: :completeCheckIn
  end
end

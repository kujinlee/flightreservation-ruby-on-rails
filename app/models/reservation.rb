class Reservation < ApplicationRecord
  self.table_name = 'reservation' # Specify singular table name to match the database schema

  # Associations
  belongs_to :passenger, foreign_key: 'passenger_id', class_name: 'Passenger'
  belongs_to :flight, foreign_key: 'flight_id', class_name: 'Flight'

  # Validations
  validates :passenger_id, presence: true
  validates :flight_id, presence: true
  validates :card_number, length: { in: 13..19 }, allow_nil: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, inclusion: { in: %w[PENDING CONFIRMED CANCELLED] }

  # Custom methods
  def self.by_passenger(passenger_id)
    where(passenger_id: passenger_id)
  end

  def self.by_flight(flight_id)
    where(flight_id: flight_id)
  end
end

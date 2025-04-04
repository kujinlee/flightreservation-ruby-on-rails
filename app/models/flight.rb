class Flight < ApplicationRecord
  self.table_name = 'flight'

  # Validations
  validates :flight_number, presence: true
  validates :operating_airlines, presence: true
  validates :departure_city, presence: true
  validates :arrival_city, presence: true
  validates :date_of_departure, presence: true
  validates :estimated_departure_time, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :by_departure_city, ->(city) { where(departure_city: city) }
  scope :by_arrival_city, ->(city) { where(arrival_city: city) }
  scope :by_date_of_departure, ->(date) { where(date_of_departure: date) }

  # Associations
  has_many :reservations, dependent: :destroy

  # Custom methods
  def self.search_flights(departure_city, arrival_city, date_of_departure)
    where(departure_city: departure_city, arrival_city: arrival_city, date_of_departure: date_of_departure)
  end
end

class Passenger < ApplicationRecord
  self.table_name = 'passenger' # Specify singular table name to match the database schema

  # Associations
  has_many :reservations, dependent: :destroy

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone, length: { is: 10 }, allow_nil: true

  # Custom methods
  def self.find_by_email(email)
    find_by(email: email)
  end

  def full_name
    [first_name, middle_name, last_name].compact.join(' ')
  end
end

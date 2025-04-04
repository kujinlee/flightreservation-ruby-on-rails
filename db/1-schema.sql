-- Create the database
CREATE DATABASE IF NOT EXISTS reservation;

-- Use the database
USE reservation;

-- Create the passenger table
CREATE TABLE IF NOT EXISTS passenger (
    id BIGINT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(256),
    last_name VARCHAR(256),
    middle_name VARCHAR(256),
    email VARCHAR(50),
    phone VARCHAR(10),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- Create the flight table
CREATE TABLE IF NOT EXISTS flight (
    id INT AUTO_INCREMENT,
    flight_number VARCHAR(50) NOT NULL,
    operating_airlines VARCHAR(255) NOT NULL,
    departure_city VARCHAR(255) NOT NULL,
    arrival_city VARCHAR(255) NOT NULL,
    date_of_departure DATE NOT NULL,
    estimated_departure_time DATETIME NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- Create the reservation table
CREATE TABLE IF NOT EXISTS reservation (
    id BIGINT NOT NULL AUTO_INCREMENT,
    passenger_id BIGINT NOT NULL,
    flight_id INT NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'CANCELLED') DEFAULT 'PENDING',
    number_of_bags INT DEFAULT 0,
    checked_in BOOLEAN DEFAULT FALSE,
    card_number VARCHAR(19), -- Updated to support 13 to 19 digits
    amount DECIMAL(10, 2),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (passenger_id) REFERENCES passenger(id) ON DELETE CASCADE,
    FOREIGN KEY (flight_id) REFERENCES flight(id) ON DELETE CASCADE
);

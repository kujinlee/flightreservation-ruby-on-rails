#!/bin/bash

# Load environment variables from .env
export $(cat .env | xargs)

# Run the Rails server
echo "Starting Rails server in non-dockerized environment..."
bundle install
rails db:setup
rails server -b 0.0.0.0 -p 3000

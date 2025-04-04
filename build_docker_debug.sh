#!/bin/bash

# Load environment variables from .env, ignoring comments and blank lines
export $(grep -v '^#' .env | grep -v '^$' | xargs)

# Build the Docker image with debug flags
echo "Building Docker image with debug flags..."
DOCKER_BUILDKIT=1 docker build --no-cache --progress=plain \
  --build-arg DATABASE_USERNAME=$DATABASE_USERNAME \
  --build-arg DATABASE_PASSWORD=$DATABASE_PASSWORD \
  --build-arg DATABASE_HOST=$DOCKER_DATABASE_HOST \
  -t flightreservation_ruby_on_rails .

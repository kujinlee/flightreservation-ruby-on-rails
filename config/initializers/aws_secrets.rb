require 'aws-sdk-secretsmanager'

def fetch_secret(secret_name)
  client = Aws::SecretsManager::Client.new(region: ENV['AWS_REGION'])
  secret = client.get_secret_value(secret_id: secret_name)
  JSON.parse(secret.secret_string)
end

if Rails.env.production?
  secrets = fetch_secret('flightreservation/secrets')

  # Use DATABASE_HOST from the environment, which is overridden by DOCKER_DATABASE_HOST in Dockerized environments.
  ENV['DATABASE_HOST'] ||= secrets['database_host'] || ENV['DATABASE_HOST']

  # Set other database credentials from AWS Secrets Manager
  ENV['DATABASE_USERNAME'] = secrets['database_username']
  ENV['DATABASE_PASSWORD'] = secrets['database_password']
end

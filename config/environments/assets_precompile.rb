Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Do not eager load code on boot.
  config.eager_load = false

  # Configure other settings as needed for the assets precompile environment.
  config.assets.compile = true
  config.assets.digest = true
end

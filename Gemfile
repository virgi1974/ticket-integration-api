source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "bootsnap", require: false # Reduces boot times through caching; required in config/boot.rb
gem "faraday"
gem "faraday-retry"
# Deploy this application anywhere as a Docker container [https://github.com/basecamp/kamal]
gem "kamal", require: false
gem "kaminari"
gem "nokogiri", "~> 1.12", ">= 1.12.4"
gem "pg", "~> 1.1" # Use postgresql as the database for Active Record
gem "puma", ">= 5.0" # Use the Puma web server [https://github.com/puma/puma]
gem "rails", "~> 8.0.1"
gem "rufus-scheduler", "~> 3.9" # Scheduler
# gem "solid_cache" # Use the database-backed adapters for Rails.cache and Active Job
# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ] # Windows does not include zoneinfo files
gem "jbuilder"
gem "redis"

# dry-rb gems
gem "dry-monads", "~> 1.6"       # For Result/Try monads
gem "dry-matcher", "~> 1.0"      # For pattern matching on monads
gem "dry-struct", "~> 1.6"       # For typed structs (useful for response objects)
gem "dry-types", "~> 1.7"        # Required by dry-struct, useful for type coercions

group :development, :test do
  gem "brakeman", require: false # Static analysis for security vulnerabilities
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "factory_bot_rails", "~> 6.4" # Test data generation
  gem "pry", "~> 0.15.2"
  gem "rspec-rails", "~> 7.1" # Testing framework
  gem "rubocop-rails-omakase", require: false # Omakase Ruby styling
  gem "shoulda-matchers", "~> 5.3" # Test matchers for models
end

# Commented out gems kept for reference
# gem "bcrypt", "~> 3.1.7" # Use Active Model has_secure_password
gem "rack-cors" # Use Rack CORS for handling Cross-Origin Resource Sharing (CORS)

group :test do
  # Add SimpleCov for test coverage reporting
  gem "simplecov", require: false
end

gem "dockerfile-rails", ">= 1.7", group: :development

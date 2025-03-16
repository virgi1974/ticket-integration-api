# Purpose: Provides Result monad pattern functionality
# Responsibilities:
# - Includes dry-monads Result and Try
# - Adds pattern matching capability
# - Standardizes Success/Failure handling
# - Enables functional composition

module Provider
  module Result
    def self.included(base)
      base.include Dry::Monads[:result]
      base.extend Dry::Monads[:result]
    end
  end
end

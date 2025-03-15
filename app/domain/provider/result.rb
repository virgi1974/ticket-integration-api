# Purpose: Provides Result monad pattern functionality
# Responsibilities:
# - Includes dry-monads Result and Try
# - Adds pattern matching capability
# - Standardizes Success/Failure handling
# - Enables functional composition

require "dry/matcher/result_matcher"

module Provider
  module Result
    def self.included(base)
      base.include Dry::Monads[:result, :try]
      base.include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)
    end
  end
end

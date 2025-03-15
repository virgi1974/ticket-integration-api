# Purpose: Defines domain-specific errors
# Responsibilities:
# - Provides custom error types
# - Enables specific error handling
# - Separates domain errors from Ruby errors
# - Helps with error classification


module Provider
  module Errors
    class Error < StandardError; end
    class NetworkError < Error; end
    class ParsingError < Error; end
    class ValidationError < Error; end
  end
end

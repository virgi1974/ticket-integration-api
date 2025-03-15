# Purpose: Configures and manages HTTP connections
# Responsibilities:
# - Configures Faraday connection
# - Manages retry logic
# - Sets timeouts
# - Provides singleton instance
# - Handles connection lifecycle

module Domain
  module Provider
    class HttpClient
      def self.configure
        @instance = new(
          Faraday.new do |f|
            f.request :retry, retry_options
            f.options.timeout = 5
            f.options.open_timeout = 2
            f.adapter Faraday.default_adapter
          end
        )
      end

      def self.instance
        @instance || configure
      end

      private_class_method :new

      def initialize(connection)
        @connection = connection
      end

      private

      def self.retry_options
        {
          max: 3,
          interval: 0.5,
          interval_randomness: 0.5,
          backoff_factor: 2,
          exceptions: [
            Faraday::ConnectionFailed,
            Faraday::TimeoutError,
            Faraday::ServerError,
            Faraday::ClientError
          ]
        }
      end
    end
  end
end

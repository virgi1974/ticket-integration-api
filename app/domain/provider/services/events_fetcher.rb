# Purpose: Handles communication with the external provider API
# Responsibilities:
# - Makes HTTP requests to fetch event data
# - Handles network errors
# - Wraps responses in our domain objects
# - Returns Success/Failure results

module Provider
  module Services
    class EventsFetcher
      include Result

      PROVIDER_URL = "https://provider.code-challenge.feverup.com/api/events"

      def initialize(http_client = HttpClient.instance)
        @http_client = http_client
      end

      def fetch
        http_response = @http_client.get(PROVIDER_URL)
        custom_response = build_response(http_response)

        if custom_response.success?
          Success(custom_response)
        else
          Failure(NetworkError.new("Server error: #{custom_response.status}"))
        end
      rescue Faraday::Error => e
        Failure(NetworkError.new(e.message))
      end

      private

      def build_response(response)
        Response.new(
          body: response.body,
          content_type: response.headers["Content-Type"],
          status: response.status
        )
      end
    end
  end
end

module Domain
  module Provider
    class EventsFetcher
      include Result

      PROVIDER_URL = "https://provider.code-challenge.feverup.com/api/events"

      def initialize(http_client = HttpClient.instance)
        @http_client = http_client
      end

      def fetch
        response = @http_client.get(PROVIDER_URL)
        Success(build_response(response))
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

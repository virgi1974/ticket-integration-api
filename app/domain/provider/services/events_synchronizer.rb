# Purpose: Orchestrates the entire event synchronization process
# Responsibilities:
# - Coordinates the fetch, parse, and persist operations
# - Manages the flow of data between components
# - Handles the result chain
# - Provides a single entry point for sync operation

module Provider
  module Services
    class EventsSynchronizer
      def initialize(fetcher:, parser:, persister:)
        @fetcher = fetcher
        @parser = parser
        @persister = persister
      end

      def self.call(fetcher:, parser:, persister:)
        new(fetcher:, parser:, persister:).call
      end

      def call
        fetch_data
          .bind { |response| parse_data(response) }
          .bind { |data| persist_data(data) }
      end

      private

      attr_reader :fetcher, :parser, :persister

      def fetch_data
        fetcher.fetch
      end

      def parse_data(response)
        parser.parse(response)
      end

      def persist_data(data)
        persister.persist(data)
      end
    end
  end
end

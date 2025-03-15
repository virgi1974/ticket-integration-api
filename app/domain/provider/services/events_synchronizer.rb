module Domain
  module Provider
    module Services
      class EventsSynchronizer
        def initialize(
          fetcher: Services::EventsFetcher.new,
          parser: Parsers::Xml.new,
          persister: Services::EventsPersister.new
        )
          @fetcher = fetcher
          @parser = parser
          @persister = persister
        end

        def self.call(
          fetcher: EventsFetcher.new,
          parser: Parsers::Xml.new,
          persister: EventsPersister.new
        )
          new(fetcher:, parser:, persister:).call
        end

        def call
          fetch_data
            .and_then { |response| parse_data(response) }
            .and_then { |data| persist_data(data) }
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
end

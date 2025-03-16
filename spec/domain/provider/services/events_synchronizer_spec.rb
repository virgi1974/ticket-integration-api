require "rails_helper"

RSpec.describe Provider::Services::EventsSynchronizer do
  include Provider::Result

  let(:fetcher) { instance_double(Provider::Services::EventsFetcher) }
  let(:parser) { instance_double(Provider::Parsers::Xml) }
  let(:persister) { instance_double(Provider::Services::EventsPersister) }

  let(:response) { instance_double(Provider::Response, success?: true) }
  let(:parsed_data) { { events: [] } }

  subject(:synchronizer) { described_class.new(fetcher:, parser:, persister:) }

  describe "#call" do
    context "when everything succeeds" do
      before do
        allow(fetcher).to receive(:fetch).and_return(Success(response))
        allow(parser).to receive(:parse).and_return(Success(parsed_data))
        allow(persister).to receive(:persist).and_return(Success(true))
      end

      it "returns Success with true" do
        result = synchronizer.call
        expect(result).to be_kind_of(Dry::Monads::Success)
        expect(result.value!).to eq(true)
      end
    end

    context "when fetch fails" do
      let(:error) { Provider::Errors::NetworkError.new("Provider API is down") }

      before do
        allow(fetcher).to receive(:fetch).and_return(Failure(error))
      end

      it "returns Failure with the network error" do
        expect(parser).not_to receive(:parse)
        expect(persister).not_to receive(:persist)

        result = synchronizer.call
        expect(result).to be_kind_of(Dry::Monads::Failure)
        expect(result.failure).to eq(error)
      end
    end
  end
end

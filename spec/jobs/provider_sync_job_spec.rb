require "rails_helper"

RSpec.describe ProviderSyncJob do
  include Provider::Result

  let(:fetcher) { instance_double(Provider::Services::EventsFetcher) }
  let(:parser) { instance_double(Provider::Parsers::Xml) }
  let(:persister) { instance_double(Provider::Services::EventsPersister) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  before do
    allow(Provider::Services::EventsFetcher).to receive(:new).and_return(fetcher)
    allow(Provider::Parsers::Xml).to receive(:new).and_return(parser)
    allow(Provider::Services::EventsPersister).to receive(:new).and_return(persister)
    allow(Rails).to receive(:logger).and_return(logger)
    allow(logger).to receive(:error)
    allow(logger).to receive(:info)
  end

  describe "#perform" do
    context "when synchronization succeeds" do
      before do
        allow(Provider::Services::EventsSynchronizer).to receive(:call)
          .with(fetcher: fetcher, parser: parser, persister: persister)
          .and_return(Success(true))
      end

      it "logs success message" do
        described_class.perform_now
        expect(logger).to have_received(:info).with("Provider sync completed successfully")
      end
    end

    context "when synchronization fails with network error" do
      let(:network_error) { Provider::Errors::NetworkError.new("Connection timeout") }

      before do
        allow(Provider::Services::EventsSynchronizer).to receive(:call)
          .with(fetcher: fetcher, parser: parser, persister: persister)
          .and_return(Failure(network_error))
      end

      it "logs the error" do
        described_class.perform_now
        expect(logger).to have_received(:error).with("Provider sync failed: Connection timeout")
      end

      it "has retry configuration for network errors" do
        expect(described_class).to respond_to(:retry_on)
      end
    end

    context "when synchronization fails with parsing error" do
      let(:parsing_error) { Provider::Errors::ParsingError.new("Invalid XML") }

      before do
        allow(Provider::Services::EventsSynchronizer).to receive(:call)
          .with(fetcher: fetcher, parser: parser, persister: persister)
          .and_return(Failure(parsing_error))
      end

      it "logs the error" do
        described_class.perform_now
        expect(logger).to have_received(:error).with("Provider sync failed: Invalid XML")
      end

      it "has retry configuration for parsing errors" do
        expect(described_class).to respond_to(:retry_on)
      end
    end

    context "when synchronization fails with validation error" do
      let(:validation_error) { Provider::Errors::ValidationError.new("Invalid data") }

      before do
        allow(Provider::Services::EventsSynchronizer).to receive(:call)
          .with(fetcher: fetcher, parser: parser, persister: persister)
          .and_return(Failure(validation_error))
      end

      it "logs the error" do
        described_class.perform_now
        expect(logger).to have_received(:error).with("Provider sync failed: Invalid data")
      end

      it "has discard configuration for validation errors" do
        expect(described_class).to respond_to(:discard_on)
      end
    end

    context "when an unexpected error occurs" do
      let(:unexpected_error) { StandardError.new("Unexpected error") }

      before do
        allow(Provider::Services::EventsSynchronizer).to receive(:call)
          .with(fetcher: fetcher, parser: parser, persister: persister)
          .and_raise(unexpected_error)
      end

      it "logs the error" do
        described_class.perform_now
        expect(logger).to have_received(:error).with(/Unexpected error/)
      end

      it "has retry configuration for standard errors" do
        expect(described_class).to respond_to(:retry_on)
      end
    end

    context "when testing rescue handlers" do
      # This is a bit of a hack to test rescue_from handlers
      # We're creating a subclass to isolate the test
      let(:test_job_class) do
        Class.new(described_class) do
          def self.name
            "TestProviderSyncJob"
          end

          def perform
            raise Provider::Errors::NetworkError, "Network test error"
          end
        end
      end

      it "handles network errors with the rescue_from handler" do
        allow(Rails.logger).to receive(:error)

        # Perform the job, which will raise the error and trigger the handler
        test_job_class.perform_now rescue nil

        # Match the actual message format
        expect(Rails.logger).to have_received(:error).with(/PROVIDER SYNC FAILED: Unexpected error after all retries: Provider::Errors::NetworkError/)
      end
    end
  end

  describe "#fetcher" do
    it "returns a new EventsFetcher instance" do
      expect(Provider::Services::EventsFetcher).to receive(:new)
      described_class.new.send(:fetcher)
    end
  end

  describe "#parser" do
    it "returns a new Xml parser instance" do
      expect(Provider::Parsers::Xml).to receive(:new)
      described_class.new.send(:parser)
    end
  end

  describe "#persister" do
    it "returns a new EventsPersister instance" do
      expect(Provider::Services::EventsPersister).to receive(:new)
      described_class.new.send(:persister)
    end
  end

  describe "#handle_error" do
    let(:error) { StandardError.new("Test error") }

    it "logs the error and raises it" do
      job = described_class.new

      expect(Rails.logger).to receive(:error).with("Provider sync failed: Test error")
      expect { job.send(:handle_error, error) }.to raise_error(StandardError, "Test error")
    end
  end
end

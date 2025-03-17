require "rails_helper"

RSpec.describe Provider::HttpClient do
  describe ".configure" do
    it "creates a new instance with configured Faraday connection" do
      # Reset the singleton instance
      described_class.instance_variable_set(:@instance, nil)

      # Mock Faraday
      faraday_connection = instance_double("Faraday::Connection")
      allow(Faraday).to receive(:new).and_yield(faraday_connection).and_return(faraday_connection)

      # Expect configuration
      expect(faraday_connection).to receive(:request).with(:retry, kind_of(Hash))
      expect(faraday_connection).to receive(:adapter).with(Faraday.default_adapter)

      # Stub options
      options = double("options")
      allow(faraday_connection).to receive(:options).and_return(options)
      expect(options).to receive(:timeout=).with(5)
      expect(options).to receive(:open_timeout=).with(2)

      # Configure
      described_class.configure

      # Verify instance was created
      expect(described_class.instance_variable_get(:@instance)).not_to be_nil
    end
  end

  describe ".instance" do
    context "when instance exists" do
      it "returns the existing instance" do
        # Create a mock instance
        mock_instance = double("HttpClient")
        described_class.instance_variable_set(:@instance, mock_instance)

        # Should return the existing instance without calling configure
        expect(described_class).not_to receive(:configure)
        expect(described_class.instance).to eq(mock_instance)
      end
    end

    context "when instance doesn't exist" do
      it "configures and returns a new instance" do
        # Reset the singleton instance
        described_class.instance_variable_set(:@instance, nil)

        # Should call configure
        expect(described_class).to receive(:configure).and_call_original

        # Get instance
        instance = described_class.instance
        expect(instance).to be_a(described_class)
      end
    end
  end

  describe "#get" do
    let(:url) { "https://api.example.com/events" }
    let(:response) { instance_double("Faraday::Response") }
    let(:connection) { instance_double("Faraday::Connection") }
    let(:client) { described_class.instance }

    before do
      # Create a client with a mock connection
      allow(Faraday).to receive(:new).and_return(connection)
      described_class.configure

      # Stub the connection's get method
      allow(connection).to receive(:get).with(url).and_return(response)
    end

    it "delegates to the Faraday connection" do
      expect(connection).to receive(:get).with(url)
      client.get(url)
    end

    it "returns the response from Faraday" do
      expect(client.get(url)).to eq(response)
    end
  end

  describe ".retry_options" do
    it "configures retry with appropriate options" do
      options = described_class.send(:retry_options)

      expect(options[:max]).to eq(3)
      expect(options[:interval]).to eq(0.5)
      expect(options[:interval_randomness]).to eq(0.5)
      expect(options[:backoff_factor]).to eq(2)
      expect(options[:exceptions]).to include(Faraday::ConnectionFailed)
      expect(options[:exceptions]).to include(Faraday::TimeoutError)
      expect(options[:exceptions]).to include(Faraday::ServerError)
      expect(options[:exceptions]).to include(Faraday::ClientError)
    end
  end

  describe "singleton pattern" do
    it "prevents direct instantiation" do
      expect { described_class.new }.to raise_error(NoMethodError)
    end

    it "always returns the same instance" do
      instance1 = described_class.instance
      instance2 = described_class.instance

      expect(instance1).to be(instance2)
    end
  end
end

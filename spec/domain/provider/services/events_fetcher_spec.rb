require "rails_helper"

RSpec.describe Provider::Services::EventsFetcher do
  include Provider::Result

  let(:http_client) { instance_double(Provider::HttpClient) }
  let(:xml_fixture) { file_fixture("xml/success_example.xml").read }
  let(:http_response) do
    instance_double(
      Faraday::Response,
      body: xml_fixture,
      headers: { "Content-Type" => "application/xml" },
      status: 200
    )
  end

  subject(:fetcher) { described_class.new(http_client) }

  describe "#fetch" do
    context "when request succeeds with valid XML" do
      before do
        allow(http_client).to receive(:get)
          .with(Provider::Services::EventsFetcher::PROVIDER_URL)
          .and_return(http_response)
      end

      it "returns Success with Response containing the XML data" do
        result = fetcher.fetch
        expect(result).to be_kind_of(Dry::Monads::Success)

        response = result.value!
        expect(response).to be_kind_of(Provider::Response)
        expect(response.body).to eq(xml_fixture)
        expect(response.content_type).to eq("application/xml")
        expect(response.status).to eq(200)
      end
    end

    context "when request fails with network error" do
      let(:network_error) { Faraday::TimeoutError.new("timeout") }

      before do
        allow(http_client).to receive(:get)
          .and_raise(network_error)
      end

      it "returns Failure with NetworkError" do
        result = fetcher.fetch
        expect(result).to be_kind_of(Dry::Monads::Failure)

        error = result.failure
        expect(error).to be_kind_of(Provider::Errors::NetworkError)
        expect(error.message).to eq("timeout")
      end
    end

    context "when server returns error status" do
      let(:error_response) do
        instance_double(
          Faraday::Response,
          body: "error",
          headers: { "Content-Type" => "text/plain" },
          status: 500
        )
      end

      before do
        allow(http_client).to receive(:get).and_return(error_response)
      end

      it "returns Failure with NetworkError" do
        result = fetcher.fetch
        expect(result).to be_kind_of(Dry::Monads::Failure)

        error = result.failure
        expect(error).to be_kind_of(Provider::Errors::NetworkError)
        expect(error.message).to include("Server error: 500")
      end
    end
  end
end

require "rails_helper"

RSpec.describe Provider::Parsers::Xml do
  include Provider::Result

  let(:xml_fixture) { File.read(Rails.root.join("spec/fixtures/files/xml/success_example.xml")) }
  let(:response) { Provider::Response.new(body: xml_fixture, content_type: "application/xml", status: 200) }

  subject(:parser) { described_class.new }

  describe "#parse" do
    context "when XML is valid" do
      it "correctly parses XML data" do
        result = parser.parse(response)
        expect(result).to be_kind_of(Dry::Monads::Success)

        data = result.value!
        expect(data[:events]).to include(
          hash_including(
            external_id: "291",
            title: "Camela en concierto",
            sell_mode: "online",
            slots: array_including(
              hash_including(
                external_id: "291",
                starts_at: "2021-06-30T21:00:00",
                ends_at: "2021-06-30T22:00:00",
                sell_from: "2020-07-01T00:00:00",
                sell_to: "2021-06-30T20:00:00",
                zones: array_including(
                  hash_including(
                    external_id: "40",
                    name: "Platea",
                    capacity: 243,
                    price: BigDecimal("20.00"),
                    numbered: true
                  )
                )
              )
            )
          )
        )
      end
    end

    context "when XML is empty" do
      let(:response) { Provider::Response.new(body: "", content_type: "application/xml", status: 200) }

      it "returns Failure with empty response error" do
        result = parser.parse(response)
        expect(result).to be_kind_of(Dry::Monads::Failure)
        expect(result.failure).to be_kind_of(Provider::Errors::ParsingError)
        expect(result.failure.message).to eq("Empty XML response")
      end
    end

    context "when XML has syntax error" do
      let(:xml_fixture) { File.read(Rails.root.join("spec/fixtures/files/xml/syntax_error_example.xml")) }
      let(:response) { Provider::Response.new(body: xml_fixture, content_type: "application/xml", status: 200) }

      it "returns Failure with syntax error" do
        result = parser.parse(response)
        expect(result).to be_kind_of(Dry::Monads::Failure)
        expect(result.failure).to be_kind_of(Provider::Errors::ParsingError)
        expect(result.failure.message).to include("FATAL")
      end
    end
  end
end

require "rails_helper"

RSpec.describe Provider::Response do
  describe ".new" do
    let(:valid_attributes) do
      {
        body: "<xml>content</xml>",
        content_type: "application/xml",
        status: 200
      }
    end

    it "creates a valid response" do
      response = described_class.new(valid_attributes)
      expect(response.body).to eq("<xml>content</xml>")
      expect(response.content_type).to eq("application/xml")
      expect(response.status).to eq(200)
    end

    it "allows nil content_type" do
      response = described_class.new(valid_attributes.merge(content_type: nil))
      expect(response.content_type).to be_nil
    end

    context "type constraints" do
      it "requires body to be a string" do
        expect {
          described_class.new(valid_attributes.merge(body: nil))
        }.to raise_error(Dry::Struct::Error)
      end

      it "requires status to be an integer" do
        expect {
          described_class.new(valid_attributes.merge(status: "200"))
        }.to raise_error(Dry::Struct::Error)
      end
    end
  end

  describe "#success?" do
    it "returns true for 2xx status codes" do
      (200..299).each do |status|
        response = described_class.new(
          body: "",
          content_type: "text/plain",
          status: status
        )
        expect(response).to be_success
      end
    end

    it "returns false for non-2xx status codes" do
      [100, 301, 404, 500].each do |status|
        response = described_class.new(
          body: "",
          content_type: "text/plain",
          status: status
        )
        expect(response).not_to be_success
      end
    end
  end

  describe "#xml?" do
    it "returns true for XML content types" do
      ["application/xml", "text/xml"].each do |content_type|
        response = described_class.new(
          body: "",
          content_type: content_type,
          status: 200
        )
        expect(response).to be_xml
      end
    end

    it "returns false for non-XML content types" do
      ["text/plain", "application/json", nil].each do |content_type|
        response = described_class.new(
          body: "",
          content_type: content_type,
          status: 200
        )
        expect(response).not_to be_xml
      end
    end
  end
end

require "rails_helper"

RSpec.describe Provider::Errors do
  describe "error hierarchy" do
    it "defines base Error class inheriting from StandardError" do
      expect(described_class::Error.superclass).to eq(StandardError)
    end

    it "defines NetworkError inheriting from Error" do
      expect(described_class::NetworkError.superclass).to eq(described_class::Error)
    end

    it "defines ParsingError inheriting from Error" do
      expect(described_class::ParsingError.superclass).to eq(described_class::Error)
    end

    it "defines ValidationError inheriting from Error" do
      expect(described_class::ValidationError.superclass).to eq(described_class::Error)
    end
  end

  describe "error instantiation" do
    it "allows creating NetworkError with message" do
      error = described_class::NetworkError.new("Connection timeout")
      expect(error.message).to eq("Connection timeout")
    end

    it "allows creating ParsingError with message" do
      error = described_class::ParsingError.new("Invalid XML format")
      expect(error.message).to eq("Invalid XML format")
    end

    it "allows creating ValidationError with message" do
      error = described_class::ValidationError.new("Invalid sell mode")
      expect(error.message).to eq("Invalid sell mode")
    end
  end
end

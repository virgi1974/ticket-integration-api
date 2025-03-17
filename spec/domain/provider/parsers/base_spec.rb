require "rails_helper"

RSpec.describe Provider::Parsers::Base do
  describe "#parse" do
    it "raises NotImplementedError" do
      parser = described_class.new
      expect { parser.parse("some content") }.to raise_error(NotImplementedError)
    end
  end

  describe "Result module" do
    it "includes the Result module" do
      expect(described_class.included_modules).to include(Provider::Result)
    end

    it "provides Success and Failure methods" do
      parser = described_class.new

      # Test Success method
      success_result = parser.Success("data")
      expect(success_result).to be_success
      expect(success_result.value!).to eq("data")

      # Test Failure method
      error = StandardError.new("error message")
      failure_result = parser.Failure(error)
      expect(failure_result).to be_failure
      expect(failure_result.failure).to eq(error)
    end
  end
end

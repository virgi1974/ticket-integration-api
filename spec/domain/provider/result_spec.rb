require "rails_helper"

RSpec.describe Provider::Result do
  let(:test_class) do
    Class.new do
      include Provider::Result

      def success_method
        Success("it worked")
      end

      def failure_method
        Failure("it failed")
      end
    end
  end

  subject(:instance) { test_class.new }

  it "provides Success method" do
    result = instance.success_method
    expect(result).to be_success
    expect(result.value!).to eq("it worked")
  end

  it "provides Failure method" do
    result = instance.failure_method
    expect(result).to be_failure
    expect(result.failure).to eq("it failed")
  end
end

require "rails_helper"

RSpec.describe Provider::ValueObjects::Event do
  let(:valid_attributes) do
    {
      external_id: "evt_123",
      title: "Summer Festival",
      sell_mode: "online"
    }
  end

  describe ".new" do
    it "creates a valid event" do
      event = described_class.new(valid_attributes)
      expect(event).to be_instance_of(described_class)
      expect(event.external_id).to eq("evt_123")
      expect(event.title).to eq("Summer Festival")
      expect(event.sell_mode).to eq("online")
    end

    context "type constraints" do
      it "requires external_id" do
        expect {
          described_class.new(valid_attributes.except(:external_id))
        }.to raise_error(Dry::Struct::Error, /:external_id is missing/)
      end

      it "requires title to be a string" do
        expect {
          described_class.new(valid_attributes.merge(title: nil))
        }.to raise_error(Dry::Struct::Error)
      end

      it "requires sell_mode to be a valid sell mode" do
        expect {
          described_class.new(valid_attributes.merge(sell_mode: "invalid"))
        }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end

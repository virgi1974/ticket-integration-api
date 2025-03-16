require "rails_helper"

RSpec.describe Provider::ValueObjects::Zone do
  let(:valid_attributes) do
    {
      external_id: "zone_123",
      slot_id: 1,
      name: "General Admission",
      capacity: 1000,
      price: BigDecimal("25.00"),
      numbered: true
    }
  end

  describe ".new" do
    it "creates a valid zone" do
      zone = described_class.new(valid_attributes)
      expect(zone).to be_instance_of(described_class)
      expect(zone.external_id).to eq("zone_123")
      expect(zone.slot_id).to eq(1)
      expect(zone.name).to eq("General Admission")
      expect(zone.capacity).to eq(1000)
      expect(zone.price).to eq(BigDecimal("25.00"))
      expect(zone.numbered).to eq(true)
    end

    context "type constraints" do
      it "requires external_id" do
        expect {
          described_class.new(valid_attributes.except(:external_id))
        }.to raise_error(Dry::Struct::Error, /:external_id is missing/)
      end

      it "requires slot_id to be an integer" do
        expect {
          described_class.new(valid_attributes.merge(slot_id: "1"))
        }.to raise_error(Dry::Struct::Error)
      end

      it "requires capacity to be a valid capacity value" do
        expect {
          described_class.new(valid_attributes.merge(capacity: -1))
        }.to raise_error(Dry::Struct::Error)
      end

      it "requires price to be a valid price value" do
        expect {
          described_class.new(valid_attributes.merge(price: -10))
        }.to raise_error(Dry::Struct::Error)
      end

      it "requires numbered to be boolean" do
        expect {
          described_class.new(valid_attributes.merge(numbered: "true"))
        }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end

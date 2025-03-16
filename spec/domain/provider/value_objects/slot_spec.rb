require "rails_helper"

RSpec.describe Provider::ValueObjects::Slot do
  let(:current_time) { Time.current }

  let(:valid_attributes) do
    {
      external_id: "slot_123",
      event_id: 1,
      starts_at: current_time.iso8601,
      ends_at: (current_time + 2.hours).iso8601,
      sell_from: (current_time - 1.day).iso8601,
      sell_to: (current_time + 1.day).iso8601
    }
  end

  describe ".new" do
    it "creates a valid slot" do
      slot = described_class.new(valid_attributes)
      expect(slot).to be_instance_of(described_class)
      expect(slot.external_id).to eq("slot_123")
      expect(slot.event_id).to eq(1)
      expect(slot.starts_at).to eq(valid_attributes[:starts_at])
      expect(slot.ends_at).to eq(valid_attributes[:ends_at])
      expect(slot.sell_from).to eq(valid_attributes[:sell_from])
      expect(slot.sell_to).to eq(valid_attributes[:sell_to])
    end

    context "type constraints" do
      it "requires external_id" do
        expect {
          described_class.new(valid_attributes.except(:external_id))
        }.to raise_error(Dry::Struct::Error, /:external_id is missing/)
      end

      it "requires event_id to be an integer" do
        expect {
          described_class.new(valid_attributes.merge(event_id: "1"))
        }.to raise_error(Dry::Struct::Error)
      end

      it "requires timestamp fields to be valid ISO8601 strings" do
        expect {
          described_class.new(valid_attributes.merge(starts_at: "invalid"))
        }.to raise_error(Dry::Struct::Error)
      end

      it "requires all timestamp fields to be present" do
        %i[starts_at ends_at sell_from sell_to].each do |field|
          expect {
            described_class.new(valid_attributes.except(field))
          }.to raise_error(Dry::Struct::Error, /#{field} is missing/)
        end
      end
    end
  end
end

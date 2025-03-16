require "rails_helper"

RSpec.describe Provider::Types do
  describe "ExternalId" do
    subject(:type) { described_class::ExternalId }

    it "accepts valid strings" do
      expect(type["123"]).to eq("123")
      expect(type["evt_456"]).to eq("evt_456")
    end

    it "rejects nil values" do
      expect { type[nil] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe "UUID" do
    subject(:type) { described_class::UUID }

    it "generates a UUID when no value provided" do
      uuid = type[]
      expect(uuid).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
    end

    it "accepts valid UUIDs" do
      uuid = SecureRandom.uuid
      expect(type[uuid]).to eq(uuid)
    end
  end

  describe "Price" do
    subject(:type) { described_class::Price }

    it "accepts decimal values" do
      expect(type[BigDecimal("10.50")]).to eq(BigDecimal("10.50"))
    end

    it "rejects non-decimal values" do
      expect { type["10.50"] }.to raise_error(Dry::Types::ConstraintError)
      expect { type[10.50] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe "Capacity" do
    subject(:type) { described_class::Capacity }

    it "accepts positive integers" do
      expect(type[100]).to eq(100)
    end

    it "accepts zero" do
      expect(type[0]).to eq(0)
    end

    it "rejects negative values" do
      expect { type[-1] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe "Timestamp" do
    subject(:type) { described_class::Timestamp }

    it "coerces ISO8601 strings to DateTime" do
      timestamp = "2024-03-14T12:00:00Z"
      expect(type[timestamp]).to eq(DateTime.parse(timestamp))
    end

    it "rejects invalid datetime strings" do
      expect { type["invalid"] }.to raise_error(Dry::Types::CoercionError)
    end
  end

  describe "SellMode" do
    subject(:type) { described_class::SellMode }

    it "accepts valid sell modes" do
      expect(type["online"]).to eq("online")
      expect(type["offline"]).to eq("offline")
    end

    it "rejects invalid sell modes" do
      expect { type["invalid"] }.to raise_error(Dry::Types::ConstraintError)
    end
  end
end

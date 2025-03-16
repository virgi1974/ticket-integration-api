require "rails_helper"

RSpec.describe Provider::Services::EventsPersister do
  include Provider::Result

  subject(:persister) { described_class.new }

  describe "#persist" do
    let(:event_data) do
      {
        events: [
          {
            external_id: "291",
            title: "Camela en concierto",
            sell_mode: "online",
            slots: [
              {
                external_id: "291",
                starts_at: DateTime.parse("2021-06-30T21:00:00"),
                ends_at: DateTime.parse("2021-06-30T22:00:00"),
                sell_from: DateTime.parse("2020-07-01T00:00:00"),
                sell_to: DateTime.parse("2021-06-30T20:00:00"),
                zones: [
                  {
                    external_id: "40",
                    name: "Platea",
                    capacity: 243,
                    price: BigDecimal("20.00"),
                    numbered: true
                  }
                ]
              }
            ]
          }
        ]
      }
    end

    context "when data is valid" do
      it "persists events, slots and zones" do
        result = persister.persist(event_data)

        expect(result).to be_kind_of(Dry::Monads::Success)

        # Verify database state
        event = Event.find_by(external_id: "291")
        expect(event).to have_attributes(
          title: "Camela en concierto",
          sell_mode: "online"
        )

        slot = event.slots.first
        expect(slot).to have_attributes(
          external_id: "291",
          starts_at: DateTime.parse("2021-06-30T21:00:00"),
          ends_at: DateTime.parse("2021-06-30T22:00:00")
        )

        zone = slot.zones.first
        expect(zone).to have_attributes(
          external_id: "40",
          name: "Platea",
          capacity: 243,
          price: BigDecimal("20.00"),
          numbered: true
        )
      end
    end

    context "when validation fails" do
      before do
        event_data[:events].first[:sell_mode] = "invalid"
      end

      it "returns Failure with validation error" do
        result = persister.persist(event_data)

        expect(result).to be_kind_of(Dry::Monads::Failure)
        expect(result.failure).to be_kind_of(Provider::Errors::ValidationError)
      end
    end
  end
end

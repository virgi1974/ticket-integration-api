require "rails_helper"

RSpec.describe Event, type: :model do
  subject(:event) { build(:event) }

  describe "associations" do
    it { should have_many(:slots) }
    it { should have_many(:current_slots).conditions(current: true).class_name("Slot") }
  end

  describe "validations" do
    it { should validate_presence_of(:uuid) }
    it { should validate_uniqueness_of(:uuid).case_insensitive }
    it { should validate_presence_of(:external_id) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:sell_mode) }
  end

  describe ".available_in_range" do
    let(:starts_at) { Time.new(2023, 1, 1) }
    let(:ends_at) { Time.new(2023, 12, 31) }

    let!(:online_event) { create(:event, sell_mode: "online") }
    let!(:offline_event) { create(:event, sell_mode: "offline") }

    let!(:current_slot_in_range) do
      create(:slot,
        event: online_event,
        current: true,
        starts_at: starts_at + 1.day,
        ends_at: ends_at - 1.day
      )
    end

    let!(:non_current_slot_in_range) do
      create(:slot,
        event: online_event,
        current: false,
        starts_at: starts_at + 1.day,
        ends_at: ends_at - 1.day
      )
    end

    let!(:current_slot_outside_range) do
      create(:slot,
        event: online_event,
        current: true,
        starts_at: starts_at - 10.days,
        ends_at: starts_at - 5.days
      )
    end

    let!(:offline_event_slot_in_range) do
      create(:slot,
        event: offline_event,
        current: true,
        starts_at: starts_at + 1.day,
        ends_at: ends_at - 1.day
      )
    end

    # Create zones for the slots
    before do
      create_list(:zone, 2, slot: current_slot_in_range)
      create_list(:zone, 2, slot: non_current_slot_in_range)
      create_list(:zone, 2, slot: current_slot_outside_range)
      create_list(:zone, 2, slot: offline_event_slot_in_range)
    end

    it "returns online events with current slots in the given date range" do
      events = Event.available_in_range(starts_at: starts_at, ends_at: ends_at)

      expect(events).to include(online_event)
      expect(events).not_to include(offline_event)
    end

    it "does not return events with only non-current slots" do
      # Create an event with only non-current slots
      event_with_non_current_slots = create(:event, sell_mode: "online")
      slot = create(:slot,
        event: event_with_non_current_slots,
        current: false,
        starts_at: starts_at + 1.day,
        ends_at: ends_at - 1.day
      )
      create_list(:zone, 2, slot: slot)

      events = Event.available_in_range(starts_at: starts_at, ends_at: ends_at)

      expect(events).not_to include(event_with_non_current_slots)
    end

    it "does not return events with slots outside the date range" do
      # Create an event with slots outside the range
      event_with_outside_slots = create(:event, sell_mode: "online")
      slot = create(:slot,
        event: event_with_outside_slots,
        current: true,
        starts_at: ends_at + 1.day,
        ends_at: ends_at + 10.days
      )
      create_list(:zone, 2, slot: slot)

      events = Event.available_in_range(starts_at: starts_at, ends_at: ends_at)

      expect(events).not_to include(event_with_outside_slots)
    end

    it "preloads current slots and zones" do
      events = Event.available_in_range(starts_at: starts_at, ends_at: ends_at)
      # Test that associations are preloaded
      events.each do |event|
        expect(event.association(:current_slots).loaded?).to be true
        event.current_slots.each do |slot|
          expect(slot.association(:zones).loaded?).to be true
        end
      end
    end

    it "returns distinct events even if they have multiple matching slots" do
      # Create another slot for the same event
      another_slot = create(:slot,
        event: online_event,
        current: true,
        starts_at: starts_at + 2.days,
        ends_at: ends_at - 2.days
      )
      create_list(:zone, 2, slot: another_slot)

      events = Event.available_in_range(starts_at: starts_at, ends_at: ends_at)

      # Should only include the event once
      expect(events.count).to eq(1)
      expect(events).to include(online_event)
    end
  end
end

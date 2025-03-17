# Purpose: Manages persistence of event data to our database
# Responsibilities:
# - Handles database transactions
# - Performs bulk upserts for better performance
# - Manages UUID generation
# - Ensures data consistency
# - Returns Success/Failure results

module Provider
  module Services
    class EventsPersister
      include Result

      def persist(data)
        ActiveRecord::Base.transaction do
          event_records = create_event_objects(data:)
          persist_event_records(event_records:)
          events_map = map_events(data:)

          # Mark existing slots as not current before creating new ones
          update_existing_slots(events_map: events_map)

          slots_data = create_slot_objects(data:, events_map:)
          created_slots = persist_slot_records(slots_data:)
          slots_map = map_slots(created_slots:)

          zones_data = create_zone_objects(data:, events_map:, slots_map:)
          persist_zone_records(zones_data:)

          Success(true)
        end
      rescue Dry::Struct::Error => e
        Failure(Provider::Errors::ValidationError.new(e.message))
      rescue StandardError => e
        Failure(e.message)
      end

      private

      def create_slot_objects(data:, events_map:)
        data[:events].flat_map do |event_data|
          event = events_map[event_data[:external_id]]
          Array(event_data[:slots]).map do |slot_data|
            ValueObjects::Slot.new(
              slot_data.merge(event_id: event.id)
            ).to_h
          end
        end
      end

      def persist_slot_records(slots_data:)
        Slot.insert_all(
          slots_data,
          returning: [ :id, :external_id, :event_id ]
        )
      end

      def map_slots(created_slots:)
        created_slots.rows.each_with_object({}) do |(id, external_id, event_id), map|
          map["#{event_id}-#{external_id}"] = id
        end
      end

      def create_zone_objects(data:, events_map:, slots_map:)
        data[:events].flat_map do |event_data|
          event = events_map[event_data[:external_id]]
          Array(event_data[:slots]).flat_map do |slot_data|
            slot_key = "#{event.id}-#{slot_data[:external_id]}"
            slot_id = slots_map[slot_key]

            Array(slot_data[:zones]).map do |zone_data|
              ValueObjects::Zone.new(
                zone_data.merge(slot_id: slot_id)
              ).to_h
            end
          end
        end
      end

      def persist_zone_records(zones_data:)
        Zone.insert_all(zones_data) if zones_data.any?
      end

      def create_event_objects(data:)
        data[:events].map do |event_data|
          ValueObjects::Event.new(event_data).to_h
        end
      end

      def persist_event_records(event_records:)
        Event.upsert_all(
            event_records,
            unique_by: :external_id,
            returning: [ :id, :external_id ]
          )
      end

      def map_events(data:)
        Event.where(external_id: data[:events].map { |e| e[:external_id] })
                           .index_by(&:external_id)
      end

      # New method to update existing slots
      def update_existing_slots(events_map:)
        event_ids = events_map.values.map(&:id)
        Slot.where(event_id: event_ids, current: true)
            .update_all(current: false)
      end
    end
  end
end

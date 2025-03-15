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
          # Collect all external IDs first
          event_ids = data[:events].map { |e| e[:external_id] }
          slot_ids = data[:events].flat_map { |e| e[:slots].map { |s| s[:external_id] } }
          zone_ids = data[:events].flat_map { |e|
            e[:slots].flat_map { |s| s[:zones].map { |z| z[:external_id] } }
          }

          # Fetch existing records in bulk
          existing_events = Event.where(external_id: event_ids).index_by(&:external_id)
          existing_slots = Slot.where(external_id: slot_ids).index_by(&:external_id)
          existing_zones = Zone.where(external_id: zone_ids).index_by(&:external_id)

          # Prepare bulk inserts/updates
          events_to_insert = []
          events_to_update = []
          slots_to_insert = []
          slots_to_update = []
          zones_to_insert = []
          zones_to_update = []

          # Process events
          data[:events].each do |event_data|
            event = existing_events[event_data[:external_id]]
            if event
              events_to_update << [event, event_data]
            else
              events_to_insert << {
                external_id: event_data[:external_id],
                uuid: SecureRandom.uuid,
                title: event_data[:title],
                sell_mode: event_data[:sell_mode],
                created_at: Time.current,
                updated_at: Time.current
              }
            end

            # Similar for slots and zones...
          end

          # Perform bulk operations
          Event.insert_all(events_to_insert) if events_to_insert.any?
          Event.upsert_all(
            events_to_update.map { |event, data|
              data.merge(id: event.id, updated_at: Time.current)
            }
          ) if events_to_update.any?

          # Similar bulk operations for slots and zones...

          Success(true)
        end
      rescue ActiveRecord::RecordInvalid => e
        Failure(ValidationError.new(e.message))
      end

      private

      def prepare_slot_data(slot_data, event_id)
        {
          external_id: slot_data[:external_id],
          uuid: SecureRandom.uuid,
          event_id: event_id,
          starts_at: slot_data[:starts_at],
          ends_at: slot_data[:ends_at],
          sell_from: slot_data[:sell_from],
          sell_to: slot_data[:sell_to],
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      def prepare_zone_data(zone_data, slot_id)
        {
          external_id: zone_data[:external_id],
          uuid: SecureRandom.uuid,
          slot_id: slot_id,
          name: zone_data[:name],
          capacity: zone_data[:capacity],
          price: zone_data[:price],
          numbered: zone_data[:numbered],
          created_at: Time.current,
          updated_at: Time.current
        }
      end
    end
  end
end

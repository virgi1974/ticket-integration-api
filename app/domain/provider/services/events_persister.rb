# Purpose: Manages persistence of event data to our database
# Responsibilities:
# - Handles database transactions
# - Creates/updates events, slots, and zones
# - Manages UUID generation
# - Ensures data consistency
# - Returns Success/Failure results

module Domain
  module Provider
    module Services
      class EventsPersister
        include Result

        def persist(data)
          ActiveRecord::Base.transaction do
            data[:events].each do |event_data|
              event = upsert_event(event_data)
              upsert_slots(event, event_data[:slots])
            end
            Success(true)
          end
        rescue ActiveRecord::RecordInvalid => e
          Failure(ValidationError.new(e.message))
        end

        private

          def upsert_event(event_data)
            Event.find_or_initialize_by(external_id: event_data[:external_id]) do |e|
              e.uuid ||= SecureRandom.uuid
            end.tap do |event|
              event.update!(
                title: event_data[:title],
                sell_mode: event_data[:sell_mode]
              )
            end
          end

          def upsert_slots(event, slots_data)
            slots_data.each do |slot_data|
              slot = upsert_slot(event, slot_data)
              upsert_zones(slot, slot_data[:zones])
            end
          end

          def upsert_slot(event, slot_data)
            event.slots.find_or_initialize_by(external_id: slot_data[:external_id]) do |s|
              s.uuid ||= SecureRandom.uuid
            end.tap do |slot|
              slot.update!(
                starts_at: slot_data[:starts_at],
                ends_at: slot_data[:ends_at],
                sell_from: slot_data[:sell_from],
                sell_to: slot_data[:sell_to]
              )
            end
          end

          def upsert_zones(slot, zones_data)
            zones_data.each do |zone_data|
              slot.zones.find_or_initialize_by(external_id: zone_data[:external_id]) do |z|
                z.uuid ||= SecureRandom.uuid
              end.tap do |zone|
                zone.update!(
                  name: zone_data[:name],
                  capacity: zone_data[:capacity],
                  price: zone_data[:price],
                  numbered: zone_data[:numbered]
                )
              end
            end
          end
      end
    end
  end
end

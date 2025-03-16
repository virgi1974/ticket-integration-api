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
          # Collect event data first
          event_data = data[:events].map do |e|
            {
              external_id: e[:external_id],
              uuid: SecureRandom.uuid,
              title: e[:title],
              sell_mode: e[:sell_mode],
              created_at: Time.current,
              updated_at: Time.current
            }
          end

          # Bulk insert events, skipping duplicates
          Event.upsert_all(
            event_data,
            unique_by: :external_id,
            returning: [ :id, :external_id ]
          )

          # Get fresh events data for associations
          events_map = Event.where(external_id: data[:events].map { |e| e[:external_id] })
                           .index_by(&:external_id)

          # Prepare slots data
          slots_data = []
          data[:events].each do |event_data|
            event = events_map[event_data[:external_id]]
            Array(event_data[:slots]).each do |slot|
              slots_data << {
                external_id: slot[:external_id],
                uuid: SecureRandom.uuid,
                event_id: event.id,
                starts_at: slot[:starts_at],
                ends_at: slot[:ends_at],
                sell_from: slot[:sell_from],
                sell_to: slot[:sell_to],
                created_at: Time.current,
                updated_at: Time.current
              }
            end
          end

          # Bulk insert slots
          created_slots = Slot.insert_all(
            slots_data,
            returning: [ :id, :external_id, :event_id ]
          )

          # Map new slot ids using composite key of event_id + external_id
          slots_map = created_slots.rows.each_with_object({}) do |(id, external_id, event_id), map|
            map["#{event_id}-#{external_id}"] = id
          end

          # Prepare zones data
          zones_data = []
          data[:events].each do |event_data|
            event = events_map[event_data[:external_id]]
            Array(event_data[:slots]).each do |slot_data|
              # Use composite key to look up correct slot
              slot_key = "#{event.id}-#{slot_data[:external_id]}"
              slot_id = slots_map[slot_key]

              Array(slot_data[:zones]).each do |zone|
                zones_data << {
                  external_id: zone[:external_id],
                  uuid: SecureRandom.uuid,
                  slot_id: slot_id,  # Now we get the correct slot_id
                  name: zone[:name],
                  capacity: zone[:capacity],
                  price: zone[:price],
                  numbered: zone[:numbered],
                  created_at: Time.current,
                  updated_at: Time.current
                }
              end
            end
          end

          # Bulk insert zones
          Zone.insert_all(zones_data) if zones_data.any?

          Success(true)
        end
      rescue ActiveRecord::RecordInvalid => e
        Failure(ValidationError.new(e.message))
      rescue StandardError => e
        Failure(e.message)
      end
    end
  end
end

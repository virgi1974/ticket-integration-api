module Api
  module V1
    class EventsController < ApplicationController
      def index
        # Get slots in the date range
        slots = Slot.in_date_range(
          starts_at: params[:starts_at],
          ends_at: params[:ends_at]
        )

        # Get the events associated with these slots
        @events = Event.where(sell_mode: "online")
                       .where(id: slots.select(:event_id))
                       .includes(slots: :zones)
                       .distinct

        render :index
      end
    end
  end
end

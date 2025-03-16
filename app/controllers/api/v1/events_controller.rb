module Api
  module V1
    class EventsController < ApplicationController
      def index
        start_time = Time.parse(params[:starts_at]) rescue nil
        end_time = Time.parse(params[:ends_at]) rescue nil

        # Return error if dates are invalid
        unless start_time && end_time
          return render json: { error: "Invalid date format" }, status: :bad_request
        end

        # Get events without pagination first
        events_query = Event.available_in_range(
          starts_at: start_time,
          ends_at: end_time
        )

        # Get page and per_page parameters with defaults
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 20).to_i

        # Apply pagination
        @events = events_query.limit(per_page).offset((page - 1) * per_page)
        # Calculate pagination metadata
        total_count = events_query.count
        @pagination = {
          current_page: page,
          per_page: per_page,
          total_count: total_count,
          total_pages: (total_count.to_f / per_page).ceil
        }

        render :index
      end
    end
  end
end

module Api
  module V1
    class EventsController < ApplicationController
      def index
        date_range = build_date_range
        return if performed?

        # Get events without pagination first
        events_query = Event.available_in_range(
          starts_at: date_range.starts_at,
          ends_at: date_range.ends_at
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

      private

      def build_date_range
        date_range = DateRange.new(
          starts_at: params[:starts_at],
          ends_at: params[:ends_at]
        )

        unless date_range.valid?
          render json: { errors: date_range.errors }, status: :bad_request
          return
        end

        date_range

      rescue Dry::Struct::Error => e
        render json: { errors: ["Invalid date format"] }, status: :bad_request
      end
    end
  end
end

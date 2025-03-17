module Api
  module V1
    class EventsController < ApplicationController
      def index
        date_range = build_date_range
        return if performed?

        # Get page and per_page parameters with defaults
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 20).to_i

        # Generate cache key
        cache_key = generate_cache_key(date_range, page, per_page)

        # Try to get from cache first
        cached_json = fetch_from_cache(cache_key)

        if cached_json
          # Log cache hit for demonstration
          Rails.logger.info "CACHE HIT: Serving events from cache"
          render json: cached_json
        else
          # Log cache miss for demonstration
          Rails.logger.info "CACHE MISS: Fetching events from database"

          # Fetch from database and render
          fetch_from_database(date_range, page, per_page)

          # Render to a string but don't send response yet
          json_response = render_to_string(:index)

          # Cache the rendered JSON
          cache_rendered_json(cache_key, json_response)

          # Send the response
          render json: json_response
        end
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
        render json: { errors: [ "Invalid date format" ] }, status: :bad_request
      end

      def generate_cache_key(date_range, page, per_page)
        EventCacheService.generate_events_key(
          date_range.starts_at,
          date_range.ends_at,
          page,
          per_page
        )
      end

      def fetch_from_cache(cache_key)
        EventCacheService.get(cache_key)
      end

      def fetch_from_database(date_range, page, per_page)
        # Get events without pagination first
        events_query = Event.available_in_range(
          starts_at: date_range.starts_at,
          ends_at: date_range.ends_at
        )

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
      end

      def cache_rendered_json(cache_key, json_response)
        EventCacheService.set(cache_key, json_response)
      end
    end
  end
end

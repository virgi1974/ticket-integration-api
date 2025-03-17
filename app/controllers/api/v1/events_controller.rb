module Api
  module V1
    class EventsController < ApplicationController
      def index
        date_range = build_date_range
        return if performed?

        # Get page and per_page parameters with defaults
        page = [params[:page].to_i, 1].max
        per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 20

        # Generate cache key
        cache_key = EventCacheService.generate_events_key(
          date_range.starts_at,
          date_range.ends_at,
          page,
          per_page
        )

        # Get the appropriate strategy
        strategy = Events::FetchStrategy.for(date_range, page, per_page, cache_key)

        # Execute the strategy
        result = strategy.execute

        if result[:from_cache]
          # Serve directly from cache
          render json: result[:json]
        else
          # Set instance variables for the view
          @events = result[:events]
          @pagination = result[:pagination]

          # Render the view
          response = render_to_string(:index)

          # Cache the rendered response
          EventCacheService.set(cache_key, response)

          # Send the response
          render json: response
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
        render json: { errors: ["Invalid date format"] }, status: :bad_request
      end
    end
  end
end

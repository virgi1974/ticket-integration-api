module Events
  class CacheMissStrategy
    def initialize(date_range, page, per_page, cache_key)
      @date_range = date_range
      @page = page
      @per_page = per_page
      @cache_key = cache_key
    end

    def execute
      Rails.logger.info "CACHE MISS: Fetching events from database"

      # Get the base query once
      base_query = Event.available_in_range(
        starts_at: @date_range.starts_at,
        ends_at: @date_range.ends_at
      )

      # Get total count from the base query
      total_count = base_query.count

      # Apply pagination to the base query
      events = base_query.limit(@per_page).offset((@page - 1) * @per_page)

      # Calculate pagination metadata
      pagination = {
        current_page: @page,
        per_page: @per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / @per_page).ceil
      }

      {
        events: events,
        pagination: pagination,
        from_cache: false
      }
    end
  end
end

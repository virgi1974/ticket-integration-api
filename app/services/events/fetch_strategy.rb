module Events
  class FetchStrategy
    def self.for(date_range, page, per_page, cache_key)
      cached_json = EventCacheService.get(cache_key)

      if cached_json
        CacheHitStrategy.new(cached_json)
      else
        CacheMissStrategy.new(date_range, page, per_page, cache_key)
      end
    end
  end
end

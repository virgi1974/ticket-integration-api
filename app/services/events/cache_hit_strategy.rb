module Events
  class CacheHitStrategy
    def initialize(cached_json)
      @cached_json = cached_json
    end

    def execute
      Rails.logger.info "CACHE HIT: Serving events from cache"
      { json: @cached_json, from_cache: true }
    end
  end
end

class EventCacheService
  # Cache TTL (1 hour by default)
  DEFAULT_TTL = 1.hour.to_i

  # Maximum number of cache entries to keep
  MAX_CACHE_ENTRIES = 100

  def self.get(cache_key)
    redis = RedisConnection.connection
    return nil unless redis

    # Try to get from cache
    cached_result = redis.get(cache_key)
    if cached_result
      # Update access time for LRU
      redis.zadd("events:lru", Time.now.to_i, cache_key)
      return cached_result  # Return the JSON string directly
    end

    nil
  end

  def self.set(cache_key, data, ttl = DEFAULT_TTL)
    redis = RedisConnection.connection
    return data unless redis

    # If data is already a string, store it directly
    # Otherwise, convert to JSON
    json_data = data.is_a?(String) ? data : data.to_json

    # Cache the result
    redis.setex(cache_key, ttl, json_data)

    # Add to LRU sorted set
    redis.zadd("events:lru", Time.now.to_i, cache_key)

    # Prune cache if needed
    prune_cache if redis.zcard("events:lru") > MAX_CACHE_ENTRIES

    data
  end

  def self.generate_events_key(starts_at, ends_at, page = nil, per_page = nil)
    if page && per_page
      "events:data:#{starts_at.to_i}_#{ends_at.to_i}:page_#{page}:per_#{per_page}"
    else
      "events:data:#{starts_at.to_i}_#{ends_at.to_i}"
    end
  end

  def self.invalidate_all
    redis = RedisConnection.connection
    return unless redis

    # Delete all event cache keys
    keys = redis.keys("events:*")
    redis.del(keys) if keys.any?

    # Clear LRU tracking
    redis.del("events:lru")
  end

  private

  def self.prune_cache
    redis = RedisConnection.connection
    return unless redis

    # Get oldest cache keys
    oldest_keys = redis.zrange("events:lru", 0, -MAX_CACHE_ENTRIES)

    # Remove them from LRU tracking and delete the cache entries
    if oldest_keys.any?
      redis.zrem("events:lru", oldest_keys)
      redis.del(oldest_keys)
    end
  end
end

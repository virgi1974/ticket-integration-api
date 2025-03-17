require "redis"

module RedisConnection
  class << self
    def connection
      @connection ||= begin
        # Rails.logger.info "Initializing Redis connection..."
        config = Rails.application.config_for(:redis).symbolize_keys
        # Rails.logger.info "Redis configuration: #{config.merge(password: '[FILTERED]').inspect}"
        Redis.new(config)
      rescue StandardError => e
        Rails.logger.error("Failed to initialize Redis: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        nil
      end
    end

    def connected?
      return false unless connection
      connection.ping == "PONG"
    rescue Redis::BaseError => e
      Rails.logger.error("Redis connection check failed: #{e.message}")
      false
    end
  end
end

# Test the connection during initialization - commented out for now
# begin
#   # Force connection initialization
#   RedisConnection.connection
#
#   if RedisConnection.connected?
#     Rails.logger.info "✅ Connected to Redis successfully"
#   else
#     Rails.logger.warn "⚠️ Redis connection test failed"
#   end
# rescue => e
#   Rails.logger.error "❌ Redis connection error during initialization: #{e.message}"
#   Rails.logger.error e.backtrace.join("\n")
# end

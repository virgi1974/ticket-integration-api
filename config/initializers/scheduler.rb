require "rufus-scheduler"

return if defined?(Rails::Console) || Rails.env.test? || File.split($PROGRAM_NAME).last == "rake"

scheduler = Rufus::Scheduler.singleton

# Fetch events from provider every 5 minutes
scheduler.every "5m", overlap: false do
  Rails.logger.info "Starting sync with providerat #{Time.current}"
end

# TODO: HEALTHCHECK of the provider health endpoint if available
# scheduler.in '10s' do
#   Rails.logger.info "Running initial provider health check at #{Time.current}"
#   ProviderSync.ping
# end

require "rufus-scheduler"

return if defined?(Rails::Console) || Rails.env.test? || File.split($PROGRAM_NAME).last == "rake"

scheduler = Rufus::Scheduler.singleton

# Fetch events from provider every 5 minutes
scheduler.every "5m", overlap: false do
  Rails.logger.info "Enqueueing provider sync job at #{Time.current}"
  ProviderSyncJob.perform_later
end

# Initial sync on service startup
scheduler.in "1s" do
  Rails.logger.info "Enqueueing initial provider sync job at #{Time.current}"
  ProviderSyncJob.perform_later
end

# TODO: HEALTHCHECK of the provider health endpoint if available
# scheduler.in '10s' do
#   Rails.logger.info "Running initial provider health check at #{Time.current}"
#   ProviderSync.ping
# end

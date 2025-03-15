class ProviderSyncJob < ApplicationJob
  queue_as :default

  # Network/HTTP errors
  retry_on Provider::Errors::NetworkError,
    wait: :exponentially_longer,
    attempts: 3,
    jitter: 0.15

  # Other errors (parsing, DB, etc)
  retry_on Provider::Errors::ParsingError,
    wait: 30.seconds,
    attempts: 2

  # Skip retries for these errors
  discard_on Provider::Errors::ValidationError

  def perform
      Provider::Services::EventsSynchronizer.call.match do |m|
      m.success { |_| Rails.logger.info("Provider sync completed successfully") }
      m.failure { |e| handle_error(e) }
    end
  end

  private

  def handle_error(error)
    Rails.logger.error("Provider sync failed: #{error.message}")
    raise error
  end
end

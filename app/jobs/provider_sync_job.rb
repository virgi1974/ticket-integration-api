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

  # Catch all other errors (with default retry settings)
  retry_on StandardError, attempts: 3

  # Skip retries for these errors
  discard_on Provider::Errors::ValidationError

  def perform
    operation = Provider::Services::EventsSynchronizer.call

    if operation.success?
      Rails.logger.info("Provider sync completed successfully")
    else
      handle_error(operation.failure)
    end
  rescue StandardError => e
    Rails.logger.error("Unexpected error: #{e.class} - #{e.message}")
    raise
  end

  private

  def handle_error(error)
    Rails.logger.error("Provider sync failed: #{error.message}")
    case error
    when StandardError
      raise error
    when Dry::Monads::Result::Failure
      raise error.value
    else
      raise "Unknown error type: #{error.class}"
    end
  end
end

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

  # Custom exception handler that runs after all retries are exhausted
  rescue_from Provider::Errors::NetworkError do |exception|
    Rails.logger.error("PROVIDER SYNC FAILED: Network error after all retries: #{exception.message}")
    # TODO: Send alert or notification
  end

  rescue_from Provider::Errors::ParsingError do |exception|
    Rails.logger.error("PROVIDER SYNC FAILED: Parsing error after all retries: #{exception.message}")
    # TODO: Send alert or notification
  end

  rescue_from StandardError do |exception|
    Rails.logger.error("PROVIDER SYNC FAILED: Unexpected error after all retries: #{exception.class} - #{exception.message}")
    # TODO: Send alert or notification
  end

  def perform
    operation = Provider::Services::EventsSynchronizer.call(
      fetcher: fetcher,
      parser: parser,
      persister: persister
    )

    if operation.success?
      Rails.logger.info("Provider sync completed successfully")
    else
      handle_error(operation.failure)
    end
  end

  private

  def fetcher
    Provider::Services::EventsFetcher.new
  end

  def parser
    Provider::Parsers::Xml.new
  end

  def persister
    Provider::Services::EventsPersister.new
  end

  def handle_error(error)
    Rails.logger.error("Provider sync failed: #{error.message}")
    raise error
  end
end

class DateRange < Dry::Struct
  include Provider::Types

  attribute :starts_at, Timestamp.optional
  attribute :ends_at, Timestamp.optional

  def valid?
    starts_at.present? && ends_at.present? && starts_at <= ends_at
  end

  def errors
    errors = []
    errors << "Start date is missing or invalid" unless starts_at.present?
    errors << "End date is missing or invalid" unless ends_at.present?
    errors << "Start date must be before end date" if starts_at.present? && ends_at.present? && starts_at > ends_at
    errors
  end
end

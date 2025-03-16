module Provider
  module Types
    include Dry.Types()

    # Basic types
    ExternalId = Types::String
    UUID = Types::String.default { SecureRandom.uuid }
    Price = Types::Decimal
    Capacity = Types::Integer.constrained(gteq: 0)
    Timestamp = Types::Params::DateTime

    # Enums
    SellMode = Types::String.enum("online", "offline")
  end
end

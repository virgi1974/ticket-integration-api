module Provider
  module ValueObjects
    class Base < Dry::Struct
      # common attributes
      attribute :uuid, Types::UUID
      attribute :external_id, Types::ExternalId
    end
  end
end

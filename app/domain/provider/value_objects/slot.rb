module Provider
  module ValueObjects
    class Slot < Base
      attribute :event_id, Types::Integer
      attribute :starts_at, Types::Timestamp
      attribute :ends_at, Types::Timestamp
      attribute :sell_from, Types::Timestamp
      attribute :sell_to, Types::Timestamp
    end
  end
end

module Provider
  module ValueObjects
    class Zone < Base
      attribute :slot_id, Types::Integer
      attribute :name, Types::String
      attribute :capacity, Types::Capacity
      attribute :price, Types::Price
      attribute :numbered, Types::Bool
    end
  end
end

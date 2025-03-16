module Provider
  module ValueObjects
    class Event < Base
      attribute :title, Types::String
      attribute :sell_mode, Types::SellMode
    end
  end
end

module Domain
  module Provider
    class Error < StandardError; end
    class NetworkError < Error; end
    class ParsingError < Error; end
    class ValidationError < Error; end
  end
end

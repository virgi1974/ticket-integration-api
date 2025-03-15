module Domain
  module Provider
    class Response < Dry::Struct
      # Define our custom types
      module Types
        include Dry.Types()
      end

      # Attributes with type safety
      attribute :body, Types::String
      attribute :content_type, Types::String.optional
      attribute :status, Types::Integer

      # Business logic methods
      def success?
        status.between?(200, 299)
      end

      def xml?
        content_type&.match?(%r{application/xml|text/xml})
      end
    end
  end
end

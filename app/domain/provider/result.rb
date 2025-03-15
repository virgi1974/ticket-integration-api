module Domain
  module Provider
    module Result
      def self.included(base)
        base.include Dry::Monads[:result, :try]
        base.include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)
      end
    end
  end
end

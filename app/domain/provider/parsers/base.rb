# Purpose: Abstract base class for data parsers
# Responsibilities:
# - Defines parser interface
# - Enforces implementation of parse method
# - Includes Result monad functionality
# - Sets foundation for different parser implementations
# - Standardizes parser behavior

module Domain
  module Provider
    module Parsers
      class Base
        include Result

        def parse(_content)
          raise NotImplementedError
        end
      end
    end
  end
end

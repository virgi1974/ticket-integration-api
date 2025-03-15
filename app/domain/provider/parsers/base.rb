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

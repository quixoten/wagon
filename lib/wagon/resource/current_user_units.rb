module Wagon
  module Request
    class CurrentUserUnits < Request::Base
      get "/current-user-units"

      def process(results)
        @stake = results.find { |result| result[:type
      end
    end
  end
end

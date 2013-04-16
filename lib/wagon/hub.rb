require "rest-client"

module Wagon
  class Hub
    attr_reader :connection

    def initialize(username, password)
      @connection = Connection.new(username, password)
    end

    def stake
    end

    def wards
    end
  end
end

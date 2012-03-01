require 'json'
require 'wagon/ward'
require 'wagon/connection'

module Wagon
  class User
    attr_reader :conn

    def initialize(username, password)
      @conn = Wagon::Connection.new(username, password)
    end

    def units
      unless @units
        resp = conn.get(:units)
        @units = JSON(resp.body)
      end
      @units
    end

    def stake
      units.first
    end

    def wards
      units.first['wards']
    end
    
    def ward_and_stake
      unless @ward_and_stake
        resp = conn.get(:user_ward_and_stake)
        @ward_and_stake = JSON(resp.body)
      end
      @ward_and_stake
    end

    def wards
    end

    def home_ward
      @ward ||= Ward.new(self)
    end

    def expired?
      conn.expired?
    end
    
    def _dump(depth)
      Marshal.dump(conn)
    end
    
    def self._load(string)
      User.allocate.instance_eval do
        @conn = Marshal.load(string)
        self
      end
    end
  end
end


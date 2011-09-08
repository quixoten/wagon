require 'json'
require 'wagon/ward'
require 'wagon/connection'

module Wagon
  class User
    attr_reader :conn

    def initialize(username, password)
      @conn = Wagon::Connection.new(username, password)
    end
    
    def ward_and_stake
      unless @ward_and_stake
        resp = conn.get(:user_ward_and_stake)
        @ward_and_stake = JSON(resp.body)
      end
      @ward_and_stake
    end
    
    def ward
      @ward ||= Ward.new(self)
    end
    
    def expired?
      conn.expired?
    end
    
    def _dump(depth)
      Marshal.dump(conn)
    end
    
    def self._load(string)
      user = User.allocate()
      user.instance_variable_set(:@conn, Marshal.load(string))
      user
    end
  end
end


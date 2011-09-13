require 'wagon/directory'
require 'json'

module Wagon
  class Ward
    attr_reader :conn, :user, :unit_number
    def initialize(user)
      @conn = user.conn
      @user = user
      @unit_number = user.ward_and_stake["wardUnitNo"]
    end

    def name
      @name ||= user.ward_and_stake["wardName"]
    end
    
    def directory
      @directory ||= Directory.new(self)
    end
    
    def households
      unless @households
        path = Connection::MAP[:households]
        resp = conn.get("#{path}#{unit_number}")
        @households = JSON(resp.body).map do |obj|
          Household.new(self, obj["headOfHouse"]["individualId"])
        end
      end
      @households
    end

    def photos
      unless @photos
        path = "#{Connection::MAP[:photos]}#{unit_number}"
        resp = conn.get(path)
        @photos = JSON(resp.body).inject({}) do |all, current|
          id = current["householdId"]
          all[id] = current["photoUrl"]
          all
        end
      end
      @photos
    end
    
    def members
      households.collect(&:members).flatten()
    end
    
    def to_pdf(options)
      directory.to_pdf(options)
    end
  end
end

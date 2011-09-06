require 'wagon/directory'

module Wagon
  class Ward
    def initialize(user)
      @user = user
      @unit_number = user.ward_and_stake["wardUnitNo"]
    end

    def user
      @user
    end

    def name
      @name ||= user.ward_and_stake["wardName"]
    end
    
    def directory
      @directory ||= Directory.new(self)
    end
    
    def households
      directory.households
    end
    
    def members
      households.collect(&:members).flatten()
    end
    
    def to_pdf(options)
      directory.to_pdf(options)
    end
  end
end

module Wagon
  class Address
    CITY_STATE_ZIP = %r/^(\D+), (\D+)?\s*(\d+(-\d+)?)?$/
    
    attr_reader :city, :state, :zip, :country
    
    def self.extract_from_string(string)
      parts   = string.split("\n").collect(&:strip).delete_if(&:empty?)
      street  = city = state = zip = country = nil
      
      parts.delete_if do |part|
        next unless part =~ CITY_STATE_ZIP
        city, state, zip = $1, ($2 || '').strip(), $3; true
      end
      
      self.new(parts.shift, city, state, zip, parts.shift)
    end
    
    def initialize(street, city, state, zip, country)
      @street, @city, @state, @zip, @country = street, city, state, zip, country
    end
    
    def street
      #601 N. Monterey Drive Apartment K
      @street.to_s.gsub(/apartment/i, 'Apt.').gsub(/drive/i, 'Dr.')
    end
    
    def to_s
      [street, [[city, state].compact.join(", "), zip, country.to_s.empty? ? nil : "(#{country})"].compact.join(" ")].compact.join("\n")
    end
    
    def ==(other)
      street  == other.street &&
      city    == other.city &&
      state   == other.state &&
      zip     == other.zip &&
      country == other.country
    end
  end
end
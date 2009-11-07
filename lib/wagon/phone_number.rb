module Wagon
  class PhoneNumber
    attr_reader :type, :value
    
    def self.extract_from_string(string)
      string.strip =~ /([\)\(\+\s\-\d]+)(\((.*)\))?$/
      self.new($3 || 'Home', $1.strip)
    end
    
    def initialize(type, value)
      @type, @value = type, value
    end
    
    def ==(other)
      type  == other.type &&
      value == other.value
    end
    
    def to_s
      self.value
    end
  end
end
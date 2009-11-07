require 'wagon/address'
require 'wagon/phone_number'
require 'wagon/member'

require 'base64'

module Wagon
  class Household
    attr_reader :connection
    attr_writer :name
    attr_accessor :address, :phone_number, :image_path, :members
    
    def initialize(connection)
      @members = []
      @connection = connection
    end
    
    def name
      self.individual? ? "#{members.first.name} #{@name}" : "#{@name} Household"
    end
    
    def individual?
      members.count == 1
    end
    
    def has_image?
      !image_path.to_s.empty?
    end
    
    def image_data
      @image_data ||= image_path.to_s.empty? ? "" : connection.get(image_path)
    end
    
    def self.create_from_td(connection, td)
      Household.new(connection).instance_eval do
        name_element, phone_element, *member_elements = *td.search('table > tr > td.eventsource[width="45%"] > table > tr > td.eventsource')
        @address = Address.extract_from_string(td.search('table > tr > td.eventsource[width="25%"]').inner_text)
        @image_path = td.at('table > tr > td.eventsource[width="30%"] > img')['src'] rescue nil
        @name = name_element.inner_text
        @phone_number = PhoneNumber.extract_from_string(phone_element.inner_text)
        
        member_elements.each_slice(2) do |name_and_email|
          name, email = *name_and_email.collect { |element| element.inner_text.gsub(/\302\240/, '').strip() }
          @members << Member.new(self, name, email)
        end
    
        self
      end
    end
  end
end
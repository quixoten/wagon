require 'wagon/address'
require 'wagon/phone_number'
require 'wagon/member'

require 'base64'

module Wagon
  class Household
    attr_reader :connection, :address, :phone_number, :image_path, :members
    
    def initialize(connection, name, address, phone_number, image_path, members)
      @connection, @name, @address, @phone_number, @image_path, @members = connection, name, address, phone_number, image_path, members
      
      if has_image?
        @connection.get_async(image_path) do |response|
          @image_data = response.body
        end
      end
    end
    
    def name
      self.individual? ? "#{members.first.name} #{@name}" : "#{@name} Household"
    end
    
    def reversed_name
      self.individual? ? "#{@name}, #{members.first.name}" : name
    end
    
    def individual?
      members.count == 1
    end
    
    def has_image?
      !image_path.to_s.empty?
    end
    
    def image_data
      return nil unless has_image?
      
      sleep(0.5) while @image_data.nil?
      
      @image_data
    end
    
    def <=>(other)
      if has_image? == other.has_image?
        reversed_name <=> other.reversed_name
      else
        has_image? ? -1 : 1
      end
    end
    
    private
    def spawn_download_thread
      @thread ||= Thread.new(image_path) do |path|
        @image_data = connection.get_async(path)
      end
    end
    
    def self.create_from_td(connection, td)
      name_element, phone_element, *member_elements = *td.search('table > tr > td.eventsource[width="45%"] > table > tr > td.eventsource')
      address       = Address.extract_from_string(td.search('table > tr > td.eventsource[width="25%"]').inner_text)
      image_path    = td.at('table > tr > td.eventsource[width="30%"] > img')['src'] rescue nil
      phone_number  = PhoneNumber.extract_from_string(phone_element.inner_text)
      members       = []
      
      member_elements.each_slice(2) do |name_and_email|
        name, email = *name_and_email.collect { |element| element.inner_text.gsub(/\302\240/, '').strip() }
        members << Member.new(self, name, email)
      end
      
      self.new(connection, name_element.inner_text, address, phone_number, image_path, members)
    end
  end
end
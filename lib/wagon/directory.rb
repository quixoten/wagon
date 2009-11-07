require 'wagon/photo_directory'
require 'prawn'

module Wagon
  class Directory < Page
    def photo_directory_path
      return @photo_directory_path unless @photo_directory_path.nil?
      
      self.at('a.linknoline[href^="javascript:confirm_photo"]')['href'].match(/^javascript:confirm_photo\('(.*)'\);$/)
      @photo_directory_path = $1
    end
    
    def photo_directory
      @photo_directory ||= PhotoDirectory.new(connection, photo_directory_path)
    end
    
    def households
      photo_directory.households
    end
    
    def members
      households.collect(&:members).flatten()
    end
    
    def to_pdf(options)
      Prawn::Document.new() do |pdf|
        households.each do |household|
          pdf.text household.name
        end
      end
    end
  end
end
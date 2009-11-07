require 'prawn'
require 'wagon/page'
require 'wagon/directory'

module Wagon
  class Ward < Page
    
    def directory_path
      @directory_path ||= self.at('a.directory[href^="/units/a/directory"]')['href']
    end
    
    def directory
      @directory ||= Directory.new(connection, directory_path)
    end
    
    def households
      directory.households
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
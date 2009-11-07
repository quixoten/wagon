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
      directory.to_pdf(options)
    end
  end
end
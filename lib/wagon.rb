module Wagon
  BASE_PATH = File.join(File.dirname(__FILE__), '..')
  VERSION = open(File.join(BASE_PATH, 'VERSION')).read()
  
  def self.connect(username, password)
    Connection.new(username, password)
  end
end

require 'wagon/connection'
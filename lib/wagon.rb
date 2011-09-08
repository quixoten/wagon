#require 'queue_to_the_future'

module Wagon
  require 'wagon/user'

  BASE_PATH = File.join(File.dirname(__FILE__), '..')
  VERSION = open(File.join(BASE_PATH, 'VERSION')).read()
  
  def self.connect(username, password)
    User.new(username, password)
  end
end



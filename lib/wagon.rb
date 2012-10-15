require 'queue_to_the_future'
require 'wagon/page'
require 'wagon/connection'

module Wagon
  def self.connect(username, password)
    Connection.new(username, password)
  end
end


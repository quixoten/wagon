require "wagon/connection"
require "wagon/constants"
require "wagon/hub"
require "wagon/stake"
require "wagon/version"

module Wagon

  ##
  # Errors
  #
  Error = Class.new(RuntimeError)
  InvalidCredentials = Class.new(Error)

  def self.connect(username, password)
    Hub.new(username, password)
  end
end

require "wagon/version"
require "wagon/constants"
require "wagon/agent"
require "wagon/stake"

module Wagon

  ##
  # Errors
  #
  Error = Class.new(RuntimeError)
  InvalidCredentials = Class.new(Error)

  def self.connect(username, password)
    Agent.new(username, password)
  end
end

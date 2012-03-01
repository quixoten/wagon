module Wagon
  require 'wagon/user'

  def self.connect(username, password)
    User.new(username, password)
  end
end



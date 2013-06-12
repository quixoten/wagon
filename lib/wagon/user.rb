require 'rest-client'

require 'wagon/request/login'
require 'wagon/ward'
require 'wagon/stake'

module Wagon
  class User
    def initialize(username, password)
      req = Request::Login.new(username, password)
      req.send_with_cookies!(@cookies)
    end
  end
end

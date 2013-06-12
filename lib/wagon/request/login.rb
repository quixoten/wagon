require 'wagon/request'

module Wagon::Request
  class Login < Struct.new(:username, :password)
    include DSL

    method :post
    uri "https://signin.lds.org/login.html"

    def send(*)
      super
    rescue RestClient::Found
      raise ArgumentError, 'Username and/or password did not match lds.org records.'
    end
  end
end

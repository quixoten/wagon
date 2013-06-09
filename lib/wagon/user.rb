require "rest-client"

require "wagon/uri"
require "wagon/ward"
require "wagon/stake"

module Wagon
  class User
    include Wagon::URI

    def initialize(username, password)
      post(LOGIN, username: username, password: password)
    rescue RestClient::Found
      raise InvalidCredentials, "Username and/or password did not match lds.org records."
    end

    def wards
      get(CURRENT_USER_UNITS)

      [Wagon::Ward.new, Wagon::Ward.new, Wagon::Ward.new]
    end

    private

    def get(url, headers = {})
      request :get, url, headers
    end

    def post(url, data = {}, headers = {})
      request :post, url, data, headers
    end

    def request(method, url, data = [], headers = {})
      headers = headers.merge(cookies: @cookies)

      response = case method
                 when :post
                   RestClient.post(url, data, headers)
                 when :get
                   RestClient.get(url, headers)
                 end

      @cookies = response.cookies

      response
    end
  end
end

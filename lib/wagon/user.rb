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

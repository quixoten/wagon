require "rest-client"

module Wagon
  class Connection
    LOGIN_URL = "https://signin.lds.org/login.html".freeze

    def initialize(username, password)
      post(LOGIN_URL, username: username, password: password)
    rescue RestClient::Found
      raise InvalidCredentials, "Username and/or password did not match lds.org records."
    end

    def get(url, headers = {})
      resp = RestClient.get(url, headers.merge(cookies: @cookies))
      @cookies = resp.cookies
      resp
    end

    def post(url, data = {}, headers = {})
      resp = RestClient.post(url, data, headers.merge(cookies: @cookies))
      @cookies = resp.cookies
      resp
    end
  end
end

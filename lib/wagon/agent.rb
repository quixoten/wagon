require "rest-client"

module Wagon
  class Agent
    def initialize(username, password)
      post(URL::LOGIN, username: username, password: password)
    rescue RestClient::Found
      raise InvalidCredentials, "Username and/or password did not match lds.org records."
    end

    def current_user_id
      unless @current_user_id
        @current_user_id = get(URL::CURRENT_USER_ID).to_s
      end

      @current_user_id
    end

    def stake
      unless @stake
        json = get(URL::CURRENT_USER_UNITS).to_s

        Stake.from_ward_and_stake_json(json)
      end

      @stake
    end

    private
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

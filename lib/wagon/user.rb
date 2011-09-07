require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'wagon/ward'

module Wagon
  class AuthenticationFailure < StandardError; end
  
  class User
    HOST = 'lds.org'
    PORT = 443
    PATHS = {
      :login => '/login.html',
      :root => '/directory/',
      :my_ward_and_stake => '/directory/services/ludrs/unit/current-user-ward-stake/'
    }
    
    attr_reader :headers
    
    def initialize(username, password)
      # @httpool = Net::HTTP::Pool.new(HOST, PORT, {:size => 20})
      response = post(:login, :username => username, :password => password)
      raise AuthenticationFailure unless response.class == HTTPOK 
      @headers = { 'Cookie' => response['Set-Cookie'] }
    end
    
    def ward_and_stake
      @ward_and_stake ||= JSON(get(:my_ward_and_stake))
    end
    
    def ward
      @ward ||= Ward.new(self)
    end
    
    def get(path)
      resp = _http.get(PATHS[path], headers)
      puts resp.content_type
    end

    def post(path, data)
      request = Net::HTTP::Post.new(PATHS[path], headers)
      request.set_form_data(data)
      _http.request(request)
    end
    
    def expired?
      _http.head(PATHS[:root]).class != Net::HTTPOK
    end
    
    def _dump(depth)
      Marshal.dump(@headers)
    end
    
    def self._load(string)
      user = User.allocate()
      user.instance_variable_set(:@headers, Marshal.load(string))
      user
    end
    
    private
    def _http
      unless @http
        @http              = Net::HTTP.new(HOST, 443)
        @http.use_ssl      = true
        @http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
        @http.start
      end

      @http
    end
  end
end

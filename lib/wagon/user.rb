require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'wagon/ward'

module Wagon
  class AuthenticationFailure < StandardError; end
  
  class User
    HOST        = 'lds.org'
    LOGIN_PATH  = '/login.html'
    
    attr_reader :cookies
    
    def initialize(username, password)
      response    = _post(LOGIN_PATH, 'username' => username, 'password' => password)
      @cookies    = response['set-cookie']

      unless response.code == "200"
        raise AuthenticationFailure.new("Invalid username and/or password")
      end
    end
    
    def ward_and_stake
      @ward_and_stake = JSON(get("/directory/services/ludrs/unit/current-user-ward-stake/"))
      def ward_and_stake
        return @ward_and_stake
      end
    end
    
    def ward
      @ward ||= Ward.new(self, home_path)
    end
    
    def get(path)
      _get(path).body
    end
    
    def expired?
      _head(ward.directory_path).class != Net::HTTPOK
    end
    
    def _dump(depth)
      Marshal.dump(@cookies)
    end
    
    def self._load(string)
      cookies = Marshal.restore(string)
      user = User.allocate()
      user.instance_variable_set(:@cookies, cookies)
      user
    end
    
    private
    def _http
      http              = Net::HTTP.new(HOST, 443)
      http.use_ssl      = true
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      http
    end
    
    def _get(path)
      attempts = 0
      _http.request(Net::HTTP::Get.new(path, {'Cookie' => @cookies || ''}))
    rescue Exception => e
      retry unless (attempts += 1) == 3
      raise e
    end
    
    def _head(path)
      _http.request(Net::HTTP::Head.new(path, {'Cookie' => @cookies || ''}))
    end
    
    def _post(path, data)
      request = Net::HTTP::Post.new(path, {'Cookie' => @cookies || ''})
      request.set_form_data(data)
      _http.request(request)
    end
  end
end

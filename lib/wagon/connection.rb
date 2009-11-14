require 'net/http'
require 'net/https'
require 'uri'
require 'digest/sha1'
require 'wagon/ward'

module Wagon
  class AuthenticationFailure < StandardError; end
  
  class Connection
    HOST        = 'secure.lds.org'
    LOGIN_PATH  = '/units/a/login/1,21568,779-1,00.html?URL='
    
    # For asynchronous procedures
    @@trigger = ConditionVariable.new
    @@lock    = Mutex.new
    @@queue   = []
    
    (1..30).collect do
      Thread.new do
        http              = Net::HTTP.new(HOST, 443)
        http.use_ssl      = true
        http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
        http
        
        while true
          connection, path, callback = nil, nil, nil
          @@lock.synchronize do
            connection, path, callback = *@@queue.shift
          end
          
          if connection
            callback.call(http.request(Net::HTTP::Get.new(path, {'Cookie' => connection.cookies || ''})))
          else
            sleep(0.5)
          end
        end
      end
    end
    
    attr_reader :cookies
    
    def initialize(username, password)
      response    = _post(LOGIN_PATH, 'username' => username, 'password' => password)
      @cookies    = response['set-cookie']
      @home_path  = URI.parse(response['location']).path

      raise AuthenticationFailure.new("Invalid username and/or password") unless @cookies
    end
    
    def home_path
      @home_path
    end
    
    def ward
      @ward ||= Ward.new(self, home_path)
    end
    
    def get(path)
      _get(path).body
    end
    
    def get_async(path, &block)
      @@lock.synchronize do
        @@queue.push([self, path, block])
      end
    end
    
    def expired?
      _head(ward.directory_path).class != Net::HTTPOK
    end
    
    def _dump(depth)
      Marshal.dump([@cookies, @home_path])
    end
    
    def self._load(string)
      attributes = Marshal.restore(string)
      connection = Connection.allocate()
      connection.instance_variable_set(:@cookies, attributes.shift)
      connection.instance_variable_set(:@home_path, attributes.shift)
      connection
    end
    
    private
    def _http
      return @http unless @http.nil?
      @http              = Net::HTTP.new(HOST, 443)
      @http.use_ssl      = true
      @http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      @http
    end
    
    def _get(path)
      _http.request(Net::HTTP::Get.new(path, {'Cookie' => @cookies || ''}))
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
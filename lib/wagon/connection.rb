require 'net/http'
require 'net/https'

module Wagon

  class AuthenticationFailure < StandardError; end

  class Connection < Net::HTTP
    MAP = {
      :root => '/directory/',
      :login => '/login.html',
      :user_ward_and_stake => '/directory/services/ludrs/unit/current-user-ward-stake/'
    }

    def initialize(username, password)
      super('lds.org', 443)
      use_ssl = true
      verify_mode = OpenSSL::SSL::VERIFY_NONE
      connect(username, password)
    end

    # def request(request)
    #   retried = false
    #   request["Set-Cookie"] = @cookies

    #  http.start unless http.started?

    #  begin
    #    http.request(request)
    #  rescue Errno::ECONNRESET => exception
    #    http.finish if http.started? 
    #    http.start

    #    if retried
    #      raise
    #    else
    #      retried = true
    #      retry
    #    end
    #  end
    #end

    def post(path, *args, &block)
      path = MAP[path] || path.to_s
      super(path, *args, &block)
    end

    def _dump(depth)
      Marshal.dump(@cookies)
    end
    
    def self._load(string)
      User.allocate.instance_eval do
        @address = 'lds.org'
        @port = 443
        @cookies = Marshal.load(string)
        use_ssl = true
        verify_mode = OpenSSL::SSL::VERIFY_NONE
        self
      end
    end

    private
    def connect(username, password)
      res = post(:login, :username => username, :password => password)

      if res === Net::HTTPOK
        @cookies = response['Set-Cookie']
      else
        raise AuthenticationFailure
      end
    end
  end
end


require 'net/http'
require 'net/https'

module Wagon

  class AuthenticationFailure < StandardError; end

  class Connection < Net::HTTP
    class << self
      alias new newobj
    end

    MAP = {
      :root => '/directory/',
      :login => '/login.html',
      :user_ward_and_stake => '/directory/services/ludrs/unit/current-user-ward-stake/'
    }

    def initialize(username, password)
      puts "cookies: #{@cookies}"
      super('lds.org', 443)
      @newimpl = true
      self.use_ssl = true
      self.verify_mode = OpenSSL::SSL::VERIFY_NONE

      unless @cookies
        _connect(username, password)
      end
    end

    def expired?
      # self.head(:root).is_a?(Net::HTTPOK)
      false
    end

    def request(req)
      retried = false
      req["Set-Cookie"] = @cookies || ""

      self.start unless self.started?

      begin
        super(req)
      rescue Errno::ECONNRESET => exception
        self.finish if self.started? 
        self.start

        if retried
          raise
        else
          retried = true
          retry
        end
      end
    end

    def get(path, *args, &block)
      path = MAP[path] || path.to_s
      super(path, *args, &block)
    end

    def head(path, *args, &block)
      path = MAP[path] || path.to_s
      super(path, *args, &block)
    end

    def post(path, data)
      path = MAP[path] || path.to_s
      req = Net::HTTP::Post.new(path)
      req.set_form_data(data)
      self.request(req)
    end

    def _dump(depth)
      Marshal.dump(@cookies)
    end
    
    def self._load(string)
      Connection.allocate.instance_eval do
        @cookies = Marshal.load(string)
        self.send(:initialize, nil, nil)
        self
      end
    end

    private
    def _connect(username, password)
      res = post(:login, :username => username, :password => password)

      if res.is_a?(Net::HTTPOK)
        @cookies = res['Set-Cookie']
      else
        raise AuthenticationFailure
      end
    end
  end
end


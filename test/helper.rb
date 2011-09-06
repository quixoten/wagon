require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'highline/import'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'wagon'

class Test::Unit::TestCase
  USER_FILE = File.join(File.dirname(__FILE__), '.user')

  def user
    self.class.user
  end

  class << self
    def user
      @user ||= create_user()
    end

    private
    def create_user
      if File.exists?(USER_FILE)
        user = Marshal.load(open(USER_FILE).read)
        return user unless user.expired?
        puts "Testing connection has timed out."
      end

      puts "Create testing connection."
      username = ask("What is your lds.org username? ")
      password = ask("What is your lds.org password? ") { |prompt| prompt.echo = "*" }

      user = Wagon::User.new(username, password)
      open(USER_FILE, 'w').write(Marshal.dump(user))
      user
    end
  end
end


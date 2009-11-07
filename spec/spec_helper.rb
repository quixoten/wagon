BASE_PATH = File.join(File.dirname(__FILE__), '..')
USER_FILE = File.join(BASE_PATH, 'spec', 'user.dat')

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(BASE_PATH, 'lib'))

require 'spec'
require 'spec/autorun'
require 'rubygems'
require 'wagon'
require 'highline/import'
require 'digest/sha1'

$user = nil

class Wagon::Connection
  def get_with_caching(path)
    cache_path = File.join(BASE_PATH, 'cache', Digest::SHA1.hexdigest(path) + ".cache")
    return open(cache_path).read if File.exists?(cache_path)
    open(cache_path, "w").write(data = get_without_caching(path))
    data
  end
  
  alias :get_without_caching :get
  alias :get :get_with_caching
end

def establish_connection
  username = ask("What is your lds.org username? ")
  password = ask("What is your lds.org password? ") { |prompt| prompt.echo = "*" }
  
  $user = Wagon::connect(username, password)
  open(USER_FILE, 'w').write(Marshal.dump($user))
end

def restore_connection
  $user = Marshal.restore(open(USER_FILE).read)
end

if File.exists?(USER_FILE)
  restore_connection()
else
  establish_connection()
end

Spec::Runner.configure do |config|
  
end

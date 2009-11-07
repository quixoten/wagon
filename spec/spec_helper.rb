BASE_PATH = File.join(File.dirname(__FILE__), '..')
USER_FILE = File.join(BASE_PATH, 'spec', 'user.dat')

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(BASE_PATH, 'lib'))

require 'spec'
require 'spec/autorun'
require 'rubygems'
require 'wagon'
require 'highline/import'

$user = nil

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

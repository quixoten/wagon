BASE_PATH = File.join(File.dirname(__FILE__), '..')
USER_FILE = File.join(BASE_PATH, 'spec', 'user.dat')
$LOAD_PATH.unshift(BASE_PATH, 'lib')
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'highline/import'
require 'wagon'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

$user = nil

def establish_connection
  puts "Create a connection for testing: "
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
  
  if $user.expired?
    puts "Previous connection timed out."
    establish_connection()
  end
else
  establish_connection()
end

RSpec.configure do |config|
  
end

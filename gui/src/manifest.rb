
# Load current and subdirectories in src onto the load path
$LOAD_PATH << File.dirname(__FILE__)
Dir.glob(File.expand_path(File.dirname(__FILE__) + "/**/*").gsub('%20', ' ')).each do |directory|
  # File.directory? is broken in current JRuby for dirs inside jars
  # http://jira.codehaus.org/browse/JRUBY-2289
  $LOAD_PATH.unshift directory unless directory =~ /\.\w+$/
end

Dir.glob(File.expand_path(File.dirname(__FILE__) + "/../lib/ruby/*/lib/").gsub('%20', ' ')).each do |directory|
  $LOAD_PATH << directory
end

require 'resolver'

case Monkeybars::Resolver.run_location
when Monkeybars::Resolver::IN_FILE_SYSTEM
  add_to_classpath '../lib/java/monkeybars-1.0.2.jar'
  add_to_load_path '../lib/ruby'
when Monkeybars::Resolver::IN_JAR_FILE
  # Files to be added only when run from inside a jar file
end

require 'monkeybars'
require 'application_controller'
require 'application_view'
require 'wagon'

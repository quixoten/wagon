require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "wagon"
    gem.summary = %Q{Create a PDF from the lds.org ward Photo Directory.}
    gem.description = %Q{Provided a valid lds.org username and password, Wagon will download all the information from the Photo Directory page and compile it into a convenient PDF.}
    gem.email = "devin@threetrieslater.com"
    gem.homepage = "http://github.com/threetrieslater/wagon"
    gem.authors = ["Devin Christensen"]
    gem.bindir = 'bin'
    gem.add_dependency "nokogiri", ">= 1.4.0"
    gem.add_dependency "highline", ">= 1.5.1"
    gem.add_dependency "prawn", ">= 0.5.1"
    gem.add_dependency "queue_to_the_future", ">= 0.1.0"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

project_path  = File.dirname(__FILE__)
version       = open("#{project_path}/VERSION").read().strip()

namespace :gui do
  def run(command)
    puts "#{command}"
    `#{command}`
  end
  
  desc "Build and unpack gem and dependencies for the gui"
  task :unpack_gem => ["check_dependencies:runtime", :build] do
    
    run("find '#{project_path}/gui/lib/ruby/' -maxdepth 1 -mindepth 1 -type d -execdir rm -r '{}' \\;")
    run("gem unpack '#{project_path}/pkg/wagon-#{version}.gem' --target='#{project_path}/gui/lib/ruby'")
    run("gem unpack queue_to_the_future --target='#{project_path}/gui/lib/ruby'")
    run("gem unpack nokogiri --target='#{project_path}/gui/lib/ruby'")
    run("gem unpack prawn --target='#{project_path}/gui/lib/ruby'")
    run("gem unpack prawn-core --target='#{project_path}/gui/lib/ruby'")
    
    Dir.glob("#{project_path}/gui/lib/ruby/*") do |path|
      next unless File.directory?(path)
      new_path = path.sub(/-(\d\.)+\d$/, '')
      run("mv '#{path}' '#{new_path}'")
    end
  end
end

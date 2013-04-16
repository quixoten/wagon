require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "spec/support"
  t.pattern = "spec/**/*_spec.rb"
end

task :default => :test

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wagon/version'

Gem::Specification.new do |gem|
  gem.name          = "wagon"
  gem.version       = Wagon::VERSION
  gem.authors       = ["Devin Christensen"]
  gem.email         = ["quixoten@gmail.com"]
  gem.description   = %Q{Provided a valid lds.org username and password, Wagon will download all the information from the Photo Directory page and compile it into a convenient PDF.}
  gem.summary       = %Q{Create a PDF from the lds.org ward Photo Directory.}
  gem.homepage      = "http://github.com/illogician/wagon"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency "nokogiri", ">= 1.4.0"
  gem.add_dependency "highline", ">= 1.5.1"
  gem.add_dependency "prawn", "~> 0.8.0"
  gem.add_dependency "queue_to_the_future", ">= 0.1.0"
  gem.add_development_dependency "rspec", "~> 2.8.0"
  gem.add_development_dependency "yard", "~> 0.7"
  gem.add_development_dependency "rdoc", "~> 3.12"
  gem.add_development_dependency "jeweler", "~> 1.8.4"
  gem.add_development_dependency "redcarpet", "~> 2.2.1"
end

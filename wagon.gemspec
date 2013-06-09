# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wagon/version'

Gem::Specification.new do |spec|
  spec.name          = "wagon"
  spec.version       = Wagon::VERSION
  spec.authors       = ["Devin Christensen"]
  spec.email         = ["quixoten@gmail.com"]
  spec.description   = %q{Wagon is a Ruby API for the tools and information available on the lds.org website}
  spec.summary       = %q{Wagon transports your ward members from lds.org}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client", "~> 1.6"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "webmock", "~> 1.11"
  spec.add_development_dependency "vcr", "~> 2.5"
  spec.add_development_dependency "pry-nav", "~> 0.2"
end

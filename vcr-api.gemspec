# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vcr/api/version'

Gem::Specification.new do |spec|
  spec.name          = "vcr-api"
  spec.version       = VCR::API::VERSION
  spec.authors       = ["Stephen Prater"]
  spec.email         = ["me@stephenprater.com"]

  spec.summary       = %q{Record requests to APIs}
  spec.description   = %q{Helper for VCR that arranges recorded requests to APIs along service boundaries.}
  spec.homepage      = "http://github.com/DOOM-SQUAD/vcr-api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "vcr", "~> 2.9.3"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "faraday", "~> 0.8.8"
  spec.add_development_dependency "fakefs"
end

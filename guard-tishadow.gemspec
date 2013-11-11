# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/tishadow/version'

Gem::Specification.new do |spec|
  spec.name          = "guard-tishadow"
  spec.version       = Guard::TishadowVersion::VERSION
  spec.authors       = ["Ian Duggan"]
  spec.email         = ["ian@ianduggan.net"]
  spec.description   = %q{Start tishadow server and push updates on changes to app directory}
  spec.summary       = %q{Start tishadow server and push updates on changes to app directory}
  spec.homepage      = "http://github.com/ijcd/guard-tishadow"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "celluloid"
  spec.add_dependency "childprocess"
end

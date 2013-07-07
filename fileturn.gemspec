# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fileturn/version'

Gem::Specification.new do |spec|
  spec.name          = "fileturn"
  spec.version       = Fileturn::VERSION
  spec.authors       = ["Nisarg Shah"]
  spec.email         = ["nisargshah100@gmail.com"]
  spec.description   = %q{FileTurn Client}
  spec.summary       = %q{FileTurn Client}
  spec.homepage      = ""

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end

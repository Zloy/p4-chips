# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'p4/chips/version'

Gem::Specification.new do |spec|
  spec.name          = "p4-chips"
  spec.version       = P4::Chips::VERSION
  spec.authors       = ["Zhan Tuaev"]
  spec.email         = ["zhoran@inbox.ru"]
  spec.summary       = %q{Provide virtual game chips, handle game and players chips balances, gains and losses}
  spec.description   = %q{See Readme at https://github.com/Zloy/p4-chips}
  spec.homepage      = "https://github.com/Zloy/p4-chips"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "rake"
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods_acknowledgements/version.rb'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-acknowledgements"
  spec.version       = CocoaPodsAcknowledgements::VERSION
  spec.authors       = ["Fabio Pelosin", "Orta Therox"]
  spec.summary       = %q{CocoaPods plugin that generates a plist which includes the everything necessary to give acknowledgements.}
  spec.homepage      = "https://github.com/CocoaPods/cocoapods-installation-metadata"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end

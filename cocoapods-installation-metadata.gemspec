# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods_install_metadata/version.rb'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-install-metadata"
  spec.version       = CocoapodsInstallMetadata::VERSION
  spec.authors       = ["Fabio Pelosin"]
  spec.summary       = %q{CocoaPods plugin that generates a plist which includes the installation metadata.}
  spec.homepage      = "https://github.com/CocoaPods/cocoapods-installation-metadata"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end

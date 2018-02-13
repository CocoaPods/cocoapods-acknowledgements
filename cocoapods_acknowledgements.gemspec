# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods_acknowledgements/version.rb'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-acknowledgements"
  spec.version       = CocoaPodsAcknowledgements::VERSION
  spec.authors       = ["Fabio Pelosin", "Orta Therox", "Marcelo Fabri"]
  spec.summary       = %q{CocoaPods plugin that generates an acknowledgements plist to make it easy to create tools to use in apps.}
  spec.homepage      = "https://github.com/CocoaPods/cocoapods-acknowledgements"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # Version 5 needs Ruby 2.2, so we specify an upper bound to stay compatible with system ruby
  spec.add_runtime_dependency 'activesupport', '>= 4.0.2', '< 5'

  spec.add_dependency "redcarpet", "~> 3.3"
  spec.add_dependency "nokogiri"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
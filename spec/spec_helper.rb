require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))
$:.unshift((ROOT + 'lib').to_s)
$:.unshift((ROOT + 'spec').to_s)

require 'bundler/setup'
require 'bacon'
require 'mocha-on-bacon'
require 'pretty_bacon'
require 'cocoapods'

require 'cocoapods_plugin'

#-----------------------------------------------------------------------------#

module Pod

  # Disable the wrapping so the output is deterministic in the tests.
  #
  UI.disable_wrap = true

  # Redirects the messages to an internal store.
  #
  module UI
    @output = ''
    @warnings = ''

    class << self
      attr_accessor :output
      attr_accessor :warnings

      def puts(message = '')
        @output << "#{message}\n"
      end

      def warn(message = '', actions = [])
        @warnings << "#{message}\n"
      end

      def print(message)
        @output << message
      end
    end
  end
end

module SpecHelper
  def self.temporary_directory
    ROOT + 'tmp'
  end

  def self.spec1
    Pod::Specification.new do |s|
      s.name = 'monkeylib'
      s.version = '1.0'
      s.authors = {
        'CocoaPods' => 'email@cocoapods.org'
      }
      s.social_media_url = 'https://twitter.com/CocoaPods'
      s.homepage = 'https://github.com/CocoaPods/monkeylib'
      s.license = {
        :type => 'MIT',
        :file => 'LICENSE',
        :text => 'Permission is hereby granted ...'
      }
      s.summary = 'A lib to do monkey things'
      s.description = <<EOF
## What is it
A lib to do monkey things
## Why?
Why not?
EOF
    end
  end

  def self.spec2
    Pod::Specification.new do |s|
      s.name         = 'BananaLib'
      s.version      = '1.0'
      s.authors      = 'Banana Corp', { 'Monkey Boy' => 'monkey@banana-corp.local' }
      s.homepage     = 'http://banana-corp.local/banana-lib.html'
      s.summary      = 'Chunky bananas!'
      s.description  = 'Full of chunky bananas.'
      s.source       = { :git => 'http://banana-corp.local/banana-lib.git', :tag => 'v1.0' }
      s.license      = {
        :type => 'MIT',
        :file => 'LICENSE',
        :text => 'Permission is hereby granted ...'
      }
      s.source_files        = 'Classes/*.{h,m,d}', 'Vendor', 'framework/Source/*.h'
      s.resources           = "Resources/*", "Resources/Images.xcassets"
      s.vendored_framework  = 'BananaFramework.framework'
      s.vendored_library    = 'libBananaStaticLib.a'
      s.preserve_paths      = 'preserve_me.txt'
      s.public_header_files = 'Classes/Banana.h', 'framework/Source/MoreBanana.h'
      s.module_map          = 'Banana.modulemap'

      s.prefix_header_file = 'Classes/BananaLib.pch'
      s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-framework SystemConfiguration' }
      s.dependency   'monkey', '~> 1.0.1', '< 1.0.9'
    end
  end
end

def temporary_sandbox
  Pod::Sandbox.new(SpecHelper.temporary_directory + 'Pods')
end

#-----------------------------------------------------------------------------#

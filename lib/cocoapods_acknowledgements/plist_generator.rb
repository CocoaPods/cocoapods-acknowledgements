require 'cocoapods_acknowledgements/markdown_parser'
require 'cocoapods_acknowledgements/generator'

module CocoaPodsAcknowledgements
  class PlistGenerator < Generator
    class SpecObject
      attr_accessor :name, :version, :authors, :socialMedialURL, :summary,
                    :description, :licenseType, :licenseText, :homepage
      def initialize(options)
        @name = options["name"]
        @version = options["version"]
        @authors = options["authors"]
        @socialMediaURL = options["socialMediaURL"]
        @summary = options["summary"]
        @description = options["description"]
        @licenseType = options["licenseType"]
        @licenseText = options["licenseText"]
        @homepage = options["homepage"]
      end
    end
    class << self
      def generate_specs(target_description, sandbox, excluded, root_specs)
        specs_metadata = []
        root_specs.each do |spec|
          pod_root = sandbox.pod_dir(spec.name)
          platform = Pod::Platform.new(target_description.platform_name)
          file_accessor = file_accessor(spec, platform, sandbox)
          license_text = license_text(spec, file_accessor)

          spec_metadata = {
              "name" => spec.name,
              "version" => spec.version,
              "authors" => spec.authors,
              "socialMediaURL" => spec.social_media_url,
              "summary" => spec.summary,
              "description" => MarkdownParser.parse_markdown(spec.description),
              "licenseType" => spec.license[:type],
              "licenseText" => license_text,
              "homepage" => spec.homepage,
          }
          specs_metadata << spec_metadata
        end
        metadata = {}
        metadata["specs"] = specs_metadata
        metadata
      end
    end
  end
end

require 'cocoapods_acknowledgements/markdown_parser'
require 'cocoapods_acknowledgements/generator'

module CocoaPodsAcknowledgements
  class PlistGenerator < Generator
    class << self
      def generate_specs(target_description, sandbox, excluded, root_specs)
        specs_metadata = []
        specs = root_specs.map do |spec|
          pod_root = sandbox.pod_dir(spec.name)
          platform = Pod::Platform.new(target_description.platform_name)
          file_accessor = file_accessor(spec, platform, sandbox)
          license_text = license_text(spec, file_accessor)

          metadata = {
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
        end
        specs_metadata += specs
        metadata = {}
        metadata["specs"] = specs_metadata
        metadata
      end
    end
  end
end

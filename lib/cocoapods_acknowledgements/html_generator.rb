require 'cocoapods_acknowledgements/markdown_parser'
require 'cocoapods_acknowledgements/generator'

module CocoaPodsAcknowledgements
  class HTMLGenerator < PlistGenerator
    class << self
      def generate_specs(target_description, sandbox, excluded, root_specs)
        metadata = super
        specs = metadata["specs"]
        metadata["specs"] = specs.map do |spec|
          spec["licenseText"] = MarkdownParser.parse_markdown(spec["licenseText"])
          Generator::SpecObject.new(spec)
        end
        metadata["header"] = header
        metadata["footer"] = footer
        metadata
      end
    end
  end
end

module CocoaPodsAcknowledgements
  class MarkdownGenerator < PlistGenerator
    class << self
      def generate_specs(target_description, sandbox, excluded, root_specs)
        metadata = super
        specs = metadata["specs"]
        metadata["specs"] = specs.map do |spec|
          Generator::SpecObject.new(spec)
        end
        metadata["header"] = header
        metadata["footer"] = footer
        metadata
      end
    end
  end
end
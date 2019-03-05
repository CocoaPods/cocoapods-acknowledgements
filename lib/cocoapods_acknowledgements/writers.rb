require 'cocoapods_acknowledgements/plist_generator'
require 'cocoapods_acknowledgements/markdown_parser'
require 'cocoapods_acknowledgements/html_layout'
module CocoaPodsAcknowledgements
  class Writers
    def self.write(metadata, filepath)
      extname = Pathname.new(filepath).extname
      case extname
        when '.plist'
          PlistWriter.write(metadata, filepath)
        when '.html'
          HTMLWriter::ERBWriter.write(metadata, filepath)
        when '.md'
          MarkdownWriter::ERBWriter.write(metadata, filepath)
      end
    end
  end

  class Writer
    class << self
      def file_externsion
        nil
      end

      def write(metadata, filepath)
        # check that extension is ok.
        # is_ok = false
        # return unless is_ok
        write_to_file(metadata, filepath)
      end

      def write_to_file(metadata, filepath)
      end
    end
  end

  class PlistWriter < Writer
    class << self
      def file_extension
        '.plist'
      end

      def write_to_file(metadata, filepath)
        if defined? Xcodeproj::Plist.write_to_path
          Xcodeproj::Plist.write_to_path(metadata, filepath)
        else
          Xcodeproj.write_plist(metadata, filepath)
        end
      end
    end
  end

  class HTMLWriter < Writer
    def self.file_extension
      '.html'
    end

    def self.write_to_file(metadata, filepath)
      # for each component of metadata we should wrap it into appropriate component.
      specs = metadata["specs"]
      header = metadata["header"]
      footer = metadata["footer"]

      builder = HTMLLayout::HTMLObjectBuilder.new do |doc|
        doc > "html" > "body"
        doc > "h1" <= header
        specs.each do |spec|
          doc > "h2" <= spec.name
          doc >= "p"
          doc << spec.licenseText
        end
        doc << footer
      end

      content = builder.layout
      File.open(filepath, 'w') do |file|
        file.write(content)
      end
    end

    class ERBWriter < HTMLWriter
      require 'erb'
      def self.write_to_file(metadata, filepath)
        binded = ["specs", "header", "footer"].reduce(binding) do |total, key|
          total.local_variable_set(key.to_sym, metadata[key])
          total
        end
        template = ERB.new %q{
          <html>
            <body>
              <h1><%= header %></h1>
              <% specs.each do |spec| %>
              <h2><%= spec.name %></h2>
              <p></p>
              <%= spec.licenseText %>
              <% end %>
              <%= footer %>
            </body>
          </html>
        }
        content = template.result(binded)
        File.open(filepath, 'w') do |file|
          file.write(content)
        end
      end
    end
  end

  class MarkdownWriter < Writer
    def self.file_extension
      '.md'
    end
    def self.write_to_file(metadata, filepath)
      specs = metadata["specs"]
      header = metadata["header"]
      footer = metadata["footer"]
      builder = HTMLLayout::MarkdownObjectBuilder.new do |doc|
        doc > "#" <= header
        specs.each do |spec|
          doc > "##" <= spec.name
          doc << spec.licenseText
        end
        doc << footer
      end
      content = builder.layout
      File.open(filepath, 'w') do |file|
        file.write(content)
      end
    end

    class ERBWriter < MarkdownWriter
      require 'erb'
      def self.write_to_file(metadata, filepath)
        binded = ["specs", "header", "footer"].reduce(binding) do |total, key|
          total.local_variable_set(key.to_sym, metadata[key])
          total
        end
        template = ERB.new %q{
# <%= header %> #

<% specs.each do |spec| %>
## <%= spec.name %> ##

<%= spec.licenseText %>
<% end %>

<%= footer %>
        }
        content = template.result(binded)
        File.open(filepath, 'w') do |file|
          file.write(content)
        end
      end
    end
  end
end
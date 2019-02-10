require 'cocoapods_acknowledgements/plist_generator'
require 'cocoapods_acknowledgements/markdown_parser'
module CocoaPodsAcknowledgements
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
    class HTMLObject
      attr_accessor :tag
      attr_accessor :children

      def tag_begin
        "<#{tag}>"
      end

      def tag_end
        "</#{tag}>"
      end

      def to_html
        [tag_begin, (children || []).map {|child| child.to_html}, tag_end].join("\n")
      end

      def << (object)
        @children ||= []
        @children << object
      end

      class << self
        def tag(tag)
          item = new
          item.tag = tag
          item
        end
      end
    end

    class PureHTMLObject < HTMLObject
      attr_accessor :content

      def tag_begin
        ""
      end

      def tag_end
        ""
      end

      def to_html
        content
      end

      class << self
        def content(html)
          new_object = new
          new_object.content = html
          new_object
        end
      end
    end

    class HTMLObjectBuilder
      attr_accessor :root_object
      attr_accessor :current_object
      attr_accessor :parent_object

      def initialize(&block)
        @root_object = nil
        @current_object = nil
        if block
          block.call(self)
        end
      end

      def tag_or_object(tag)
        if tag.is_a? HTMLObject
          tag
        else
          HTMLObject.tag tag
        end
      end

      def open(tag)
        new_object = tag_or_object tag
        unless @root_object
          @root_object = new_object
          @current_object = @root_object
          @parent_object = @root_object
        else
          @parent_object = @current_object
          @current_object << new_object
          @current_object = new_object
        end
      end

      def close
        @current_object = @parent_object
      end

      def tag(tag, &block)
        self.open tag
        if block
          block.call(self)
        end
        self.close
      end

      def content(html)
        @current_object << PureHTMLObject.content(html)
      end

      def to_html
        root_object.to_html
      end

      # MARK: DSL
      def > (tag)
        self.open tag
        self
      end
      def !
        self.close
        self
      end
      def << (html)
        self.content(html)
        self
      end
      def >= (tag)
        self > tag
        !self
      end
      def <= (html)
        self << html
        !self
        # self.content(html)
        # self.close
        # self
      end
    end

    class << self
      def file_extension
        '.html'
      end

      def write_to_file(metadata, filepath)
        # for each component of metadata we should wrap it into appropriate component.
        specs = metadata["specs"]
        header = metadata["header"]
        footer = metadata["footer"]

        builder = HTMLObjectBuilder.new do |doc|
          doc > "html" > "body"
          doc > "h1" <= header
          specs.each do |spec|
            doc > "h2" <= spec.name
            doc >= "p"
            doc << MarkdownParser.parse_markdown(spec.licenseText)
          end
          doc <= footer
        end

        content = builder.to_html
        File.open(filepath, 'w') do |file|
          file.write(content)
        end
      end
    end
  end
end
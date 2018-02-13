require 'redcarpet'

module CocoaPodsAcknowledgements
  class MarkdownParser
    class << self
      def markdown_parser
        @markdown_parser ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      end

      def parse_markdown(text)
        return nil unless text
        markdown_parser.render(text)
      end
    end
  end
end
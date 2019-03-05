require 'redcarpet'

module CocoaPodsAcknowledgements
  class MarkdownParser
    class << self
      def markdown_parser(render_options)
        @markdown_parser ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, render_options)
      end

      def parse_markdown(text, render_options = {})
        return nil unless text
        markdown_parser(render_options).render(text)
      end
    end
  end
end
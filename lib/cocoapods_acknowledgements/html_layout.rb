module CocoaPodsAcknowledgements
  module HTMLLayout
  end
end

module CocoaPodsAcknowledgements::HTMLLayout
  class HTMLObject
    attr_accessor :tag
    attr_accessor :children

    def tag_begin
      "<#{tag}>"
    end

    def tag_end
      "</#{tag}>"
    end

    def layout
      [tag_begin, children.map(&:layout), tag_end].join("\n")
    end

    def initialize
      @children = []
    end

    def << (object)
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
end

module CocoaPodsAcknowledgements::HTMLLayout
  class MarkdownObject < HTMLObject
    def tag_begin
      tag
    end
    def tag_end
      tag
    end
    def layout
        ([
          [tag_begin, children.first.layout, tag_end].join(" ")
        ] + children.drop(1).map(&:layout)).join("\n\n")
    end
  end
end

module CocoaPodsAcknowledgements::HTMLLayout
  class ContentObject < HTMLObject
    attr_accessor :content

    def tag_begin
      ""
    end

    def tag_end
      ""
    end

    def layout
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
end

module CocoaPodsAcknowledgements::HTMLLayout
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

    def base_object
      HTMLObject
    end

    def tag_or_object(tag)
      if tag.is_a? base_object
        tag
      else
        base_object.tag tag
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
      @current_object << ContentObject.content(html)
    end

    def layout
      root_object.layout
    end
  end
end

# MARK: DSL
class CocoaPodsAcknowledgements::HTMLLayout::HTMLObjectBuilder
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
  end
end

module CocoaPodsAcknowledgements::HTMLLayout
  class MarkdownObjectBuilder < HTMLObjectBuilder
    def base_object
      MarkdownObject
    end
  end
end

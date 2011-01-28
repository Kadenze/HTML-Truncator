# encoding: utf-8

require "nokogiri"
require "set"


class HTML_Truncator
  DEFAULT_OPTIONS = { :ellipsis => "…", :length_in_chars => false }

  def self.truncate(text, max, opts={})
    return truncate(text, max, :ellipsis => opts) if String === opts
    opts = DEFAULT_OPTIONS.merge(opts)
    doc = Nokogiri::HTML::DocumentFragment.parse(text)
    doc.truncate(max, opts).first
  end

  class <<self
    attr_accessor :ellipsable_tags
  end
  self.ellipsable_tags = Set.new(%w(p ol ul li div header article nav section footer aside dd dt dl))
end


class Nokogiri::HTML::DocumentFragment
  def ellipsable?
    true
  end
end

class Nokogiri::XML::Node
  def truncate(max, opts)
    return ["", 1, opts] if max == 0 && !ellipsable?
    inner, remaining, opts = inner_truncate(max, opts)
    children.remove
    add_child Nokogiri::HTML::DocumentFragment.parse(inner)
    [to_html(:indent => 0), max - remaining, opts]
  end

  def inner_truncate(max, opts)
    inner, remaining = "", max
    self.children.each do |node|
      txt, nb, opts = node.truncate(remaining, opts)
      remaining -= nb
      inner += txt
      next if remaining >= 0
      if ellipsable?
        inner += opts[:ellipsis]
        opts[:ellipsis] = ""
      end
      break
    end
    [inner, remaining, opts]
  end

  def ellipsable?
    HTML_Truncator.ellipsable_tags.include? name
  end
end

class Nokogiri::XML::Text
   def truncate(max, opts)
     if opts[:length_in_chars]
       count = content.length
       return [to_xhtml, count, opts] if count <= max && max > 0
       [content.slice(0, max), count, opts]
     else
       words = content.split
       count = words.length
       return [to_xhtml, count, opts] if count <= max && max > 0
       [words.slice(0, max).join(' '), count, opts]
     end
  end
end

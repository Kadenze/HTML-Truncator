# encoding: utf-8
path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require "html_truncator"


describe HTML_Truncator do
  let(:short_text) { "<p>Foo <b>Bar</b> Baz</p>" }
  let(:long_text)  { "<p>Foo " +  ("<b>Bar Baz</b> " * 100) + "Quux</p>" }
  let(:list_text)  { "<p>Foo:</p><ul>" +  ("<li>Bar Baz</li>\n" * 100) + "</ul>" }

  it "should not modify short text" do
    HTML_Truncator.truncate(short_text, 10).should == short_text
  end

  it "should truncate long text to the given number of words" do
    words = HTML_Truncator.truncate(long_text, 10, :ellipsis => "").gsub(/<[^>]*>/, ' ').split
    words.should have(10).items
    words = HTML_Truncator.truncate(long_text, 11, :ellipsis => "").gsub(/<[^>]*>/, '').split
    words.should have(11).items
  end

  it "should not contains empty DOM nodes" do
    HTML_Truncator.truncate(long_text, 10, :ellipsis => "...").should_not =~ /<b>\s*<\/b>/
    HTML_Truncator.truncate(long_text, 11, :ellipsis => "...").should_not =~ /<b>\s*<\/b>/
    HTML_Truncator.truncate(list_text, 10, :ellipsis => "...").should_not =~ /<li>\s*<\/li>/
    HTML_Truncator.truncate(list_text, 11, :ellipsis => "...").should_not =~ /<li>\s*<\/li>/
  end

  it "should truncate long text with an ellipsis inside the last DOM node" do
    HTML_Truncator.truncate(list_text, 10, :ellipsis => "...").should =~ /\.\.\.<\/li>\s*<\/ul>$/
  end

  it "should accept an ellipsis as last argument (not an options hash)" do
    HTML_Truncator.truncate(long_text, 3, "...").should == "<p>Foo <b>Bar Baz</b>...</p>"
    HTML_Truncator.truncate(long_text, 4, "...").should == "<p>Foo <b>Bar Baz</b> <b>Bar</b>...</p>"
  end

  it "should truncate long text" do
    HTML_Truncator.truncate(long_text, 3, :ellipsis => "...").should == "<p>Foo <b>Bar Baz</b>...</p>"
    HTML_Truncator.truncate(long_text, 4, :ellipsis => "...").should == "<p>Foo <b>Bar Baz</b> <b>Bar</b>...</p>"
    HTML_Truncator.truncate(list_text, 3, :ellipsis => "...").should == "<p>Foo:</p><ul><li>Bar Baz</li>\n<li>...</li>\n</ul>"
    HTML_Truncator.truncate(list_text, 4, :ellipsis => "...").should == "<p>Foo:</p><ul><li>Bar Baz</li>\n<li>Bar...</li></ul>"
  end

  it "should be possible to truncate with HTML in the ellipsis" do
    HTML_Truncator.truncate(long_text, 2, :ellipsis => ' <a href="/more">...</a>').should == '<p>Foo <b>Bar</b> <a href="/more">...</a></p>'
  end

  it "should preserve spaces inside a node" do
    HTML_Truncator.truncate("<p>bla bla bla bla bla</p>", 2, :ellipsis => "...").should == "<p>bla bla...</p>"
  end

  it "should not bug on pre" do
    HTML_Truncator.truncate("<p>foo bar</p><pre>foo bar</pre>", 3, :ellipsis => "...").should == "<p>foo bar</p><pre>foo</pre>..."
  end

  it "should not bug on françois test" do
    HTML_Truncator.truncate("<p>foo bar</p><pre>foo bar</pre>plop", 3, :ellipsis => "...").should == "<p>foo bar</p><pre>foo</pre>..."
    HTML_Truncator.truncate("<p>Foo <b>Bar Baz</b> plop<b>Foo Bar</b></p>", 3, :ellipsis => "...").should == "<p>Foo <b>Bar Baz</b>...</p>"
  end

  it "should consider <p> as an element that can contains the ellipsis" do
    HTML_Truncator.ellipsable_tags.should include("p")
  end

  it "should be possible to mark a tag as ellipsable" do
    HTML_Truncator.ellipsable_tags << "blockquote"
    HTML_Truncator.truncate("<blockquote>Foo bar baz quux</blockquote>", 3, :ellipsis => "...").should == "<blockquote>Foo bar baz...</blockquote>"
  end

  it "should not bug on deep nested tags" do
    txt = "<article><ul><li>Foo Bar</li><li><b><u><s>baz</s> quux</u></b></li></ul></article>"
    truncated = HTML_Truncator.truncate(txt, 3, :ellipsis => "...").gsub("\n", "")
    truncated.should == "<article><ul><li>Foo Bar</li><li><b><u><s>baz</s></u></b>...</li></ul></article>"
  end

  it "can truncate with a characters length" do
    HTML_Truncator.truncate(long_text, 11, :ellipsis => "...", :length_in_chars => true).should == "<p>Foo <b>Bar Baz</b>...</p>"
    HTML_Truncator.truncate(long_text, 15, :ellipsis => "...", :length_in_chars => true).should == "<p>Foo <b>Bar Baz</b> <b>Bar</b>...</p>"
  end
end

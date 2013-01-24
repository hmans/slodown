require 'spec_helper'

def render(text)
  Slodown::Formatter.new(text).complete.to_s
end

describe 'basic formatting syntax' do
  # Just a silly little spec to get things started. I don't intend
  # to test the whole of kramdown here. :)~
  #
  it "renders **this** as bold text" do
    expect(render "**foo**").to eq "<p><strong>foo</strong></p>"
  end
  it "highlights syntax in fenced code blocks" do
    example = "```ruby\nhello.world :sym, true\n```"
    result = "<div class=\"CodeRay\">\n  <div class=\"code\"><pre>\nhello.world <span style=\"color:#A60\">:sym</span>, <span style=\"color:#069\">true</span>\n</pre></div>\n</div>"
    expect(render(example)).to eq result
  end
end

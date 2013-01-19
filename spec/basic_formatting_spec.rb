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
end

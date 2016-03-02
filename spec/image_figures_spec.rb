require 'spec_helper'

def render(text)
  Slodown::Formatter.new(text).complete.to_s
end

describe 'basic formatting syntax' do
  # Just a silly little spec to get things started. I don't intend
  # to test the whole of kramdown here. :)~
  #
  it "converts a block-level image to a <figure> structure" do
    expect(render %[check it out:\n\n![image](image.jpg "Cute Kitten!")])
      .to eq %[<p>check it out:</p>\n\n<figure><img src="image.jpg" alt="image" title="Cute Kitten!"><figcaption>Cute Kitten!</figcaption></figure>\n]
  end

  it "doesn't affect OEmbed-enabled embeds" do
    expect(render %[check it out:\n\n![video](https://www.youtube.com/watch?v=KilehMXMxo0)])
      .to eq %[<p>check it out:</p>\n\n<div class="embedded video youtube"><iframe width="480" height="270" src="https://www.youtube.com/embed/KilehMXMxo0?feature=oembed" frameborder="0" allowfullscreen=""></iframe></div>]
  end

  it "doesn't affect inline images" do
    expect(render %[here's an inline image: ![image](image.jpg)])
      .to eq %[<p>here’s an inline image: <img src="image.jpg" alt="image"></p>\n]
  end
end

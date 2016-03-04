# This is the custom kramdown converter class we will be using to render
# HTML from Markdown. It's essentially a handy way to hook into various
# elements and add our own logic (like supporting oEmbed embeds in
# Markdown image elements.)
#
class Kramdown::Converter::SlodownHtml < Kramdown::Converter::Html
  # In Slodown, you can use block-level image attributes for oEmbed-based
  # embeds. For this, we're hooking into #convert_p to find single block-level
  # images.
  #
  # If we can't use OEmbed, we'll assume the image is an actual image, and
  # convert it into a <figure> element (with optional <figcaption>.)
  #
  def convert_p(el, indent)
    if el.options[:transparent]
      inner(el, indent)
    elsif !el.children.nil? && el.children.count == 1 && el.children.first.type == :img
      # Try to handle the embedded object through OEmbed; if this fails,
      # handle it as an image instead and create a <figure>.
      child = el.children.first

      begin
        oembed = OEmbed::Providers.get(child.attr['src'])
        %q(<div class="embedded %s %s">%s</div>) % [oembed.type, oembed.provider_name.downcase.gsub(/\W+/, '-'), oembed.html]
      rescue OEmbed::NotFound => e
        convert_figure(child, indent)
      end
    else
      super
    end
  end

  def convert_figure(el, indent)
    "#{' '*indent}<figure><img#{html_attributes(el.attr)} />#{(el.attr['title'] ? "<figcaption>#{el.attr['title']}</figcaption>" : "")}</figure>\n"
  end
end

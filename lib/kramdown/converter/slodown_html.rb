# This is the custom kramdown converter class we will be using to render
# HTML from Markdown. It's essentially a handy way to hook into various
# elements and add our own logic (like supporting oEmbed embeds in
# Markdown image elements.)
#
class Kramdown::Converter::SlodownHtml < Kramdown::Converter::Html
  def convert_img(el, indent)
    oembed = OEmbed::Providers.get(el.attr['src'])
    %q(<div class="embedded %s %s">%s</div>) % [oembed.type, oembed.provider_name.parameterize, oembed.html]
  rescue OEmbed::NotFound
    super
  end
end

require 'oembed'
require 'rinku'
require 'kramdown'
require 'coderay'
require 'sanitize'

require "slodown/version"

OEmbed::Providers.register_all

class Kramdown::Converter::SloblogHtml < Kramdown::Converter::Html
  def convert_img(el, indent)
    oembed = OEmbed::Providers.get(el.attr['src'])
    %q(<div class="embedded %s %s">%s</div>) % [oembed.type, oembed.provider_name.parameterize, oembed.html]
  rescue OEmbed::NotFound
    super
  end
end

module Slodown
  class EmbedTransformer
    ALLOWED_DOMAINS = %w[youtube.com soundcloud.com vimeo.com]

    def self.call(env)
      node      = env[:node]
      node_name = env[:node_name]

      return if env[:is_whitelisted] || !env[:node].element?
      return unless %w[iframe embed].include? env[:node_name]

      uri = URI(env[:node]['src'])
      domains = ALLOWED_DOMAINS.map { |d| Regexp.escape(d) }.join("|")
      return unless uri.host =~ /^(.+\.)?(#{domains})/

      Sanitize.clean_node!(node, {
        elements: %w[iframe embed],
        attributes: {
          all: %w[allowfullscreen frameborder height src width]
        }
      })

      { node_whitelist: [node] }
    end
  end

  class Formatter
    def initialize(source)
      @current = @source = source.to_s
    end

    def complete
      markdown.autolink.sanitize
    end

    def markdown
      @current = Kramdown::Document.new(@current).to_sloblog_html
      self
    end

    def autolink
      @current = Rinku.auto_link(@current)
      self
    end

    def sanitize(mode = :normal)
      @current = case mode
      when :normal
        Sanitize.clean(@current,
          elements: %w(
            p a span sub sup strong em div hr abbr
            ul ol li
            blockquote pre code
            h1 h2 h3 h4 h5 h6
            img object param del
          ),
          attributes: {
            :all     => ['class', 'style', 'title'],
            'a'      => ['href', 'rel', 'name'],
            'li'     => ['id'],
            'sup'    => ['id'],
            'img'    => ['src', 'title', 'alt', 'width', 'height'],
            'object' => ['width', 'height'],
            'param'  => ['name', 'value'],
            'embed'  => ['allowscriptaccess', 'width', 'height', 'src'],
            'iframe' => ['width', 'height', 'src']
          },
          protocols: {
            'a' => { 'href' => ['ftp', 'http', 'https', 'mailto', '#fn', '#fnref', :relative] },
            'img' => {'src'  => ['http', 'https', :relative]},
            'iframe' => {'src'  => ['http', 'https']},
            'embed' => {'src'  => ['http', 'https']},
            'object' => {'src'  => ['http', 'https']},
            'li' => {'id' => ['fn']},
            'sup' => {'id' => ['fnref']}
          },
          transformers: EmbedTransformer)
      else
        Sanitize.clean(@current)
      end

      self
    end

    def to_s
      @current
    end
  end
end

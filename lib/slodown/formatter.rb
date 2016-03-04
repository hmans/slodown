module Slodown
  # This is the base Formatter class provided by Slodown. It works right
  # out of the box if you want to use exactly the functionality provided by
  # it, but in most projects, you'll probably want to create a new class
  # inheriting from this one, selectively overriding methods like
  # +kramdown_options+ or adding your own.
  #
  class Formatter
    attr_reader :metadata

    def initialize(source)
      @current = @source = source.to_s
      @metadata = {}
    end

    # Run the entire pipeline in a sane order.
    #
    def complete
      extract_metadata.markdown.autolink.sanitize
    end

    # Convert the current document state from Markdown into HTML.
    #
    def markdown
      convert do |current|
        Kramdown::Document.new(current, kramdown_options).to_slodown_html
      end
    end

    # Auto-link URLs through Rinku.
    #
    def autolink
      convert do |current|
        Rinku.auto_link(current)
      end
    end

    # Sanitize HTML tags.
    #
    def sanitize
      convert do |current|
        Sanitize.clean(current, sanitize_config)
      end
    end

    # Extract metadata from the document.
    #
    def extract_metadata
      @metadata = {}

      convert do |current|
        current.each_line.drop_while do |line|
          next false if line !~ /^#\+([a-z_]+): (.*)/

          key, value = $1, $2
          @metadata[key.to_sym] = value
        end.join('')
      end
    end

    def to_s
      @current
    end

    # Return a hash of configuration values for kramdown. Please refer to
    # the documentation of kramdown for details:
    #
    # http://kramdown.gettalong.org/options.html
    #
    def kramdown_options
      {
        syntax_highlighter: defined?(Rouge) ? 'rouge' : 'coderay',
        syntax_highlighter_opts: { }
      }
    end

    # Return a hash of configuration values for the sanitize gem. Please refer
    # to the documentation for sanitize for details:
    #
    # https://github.com/rgrove/sanitize#custom-configuration
    #
    def sanitize_config
      {
        elements: %w(
          p br a span sub sup strong em div hr abbr s
          ul ol li
          blockquote cite pre code kbd
          h1 h2 h3 h4 h5 h6
          img object param del
          table tr td th
          figure figcaption
          mark del ins
        ),
        attributes: {
          :all     => ['class', 'style', 'title', 'id', 'datetime'],
          'a'      => ['href', 'rel', 'name'],
          'li'     => ['id'],
          'sup'    => ['id'],
          'img'    => ['src', 'title', 'alt', 'width', 'height'],
          'object' => ['width', 'height'],
          'param'  => ['name', 'value'],
          'embed'  => ['allowscriptaccess', 'width', 'height', 'src'],
          'iframe' => ['width', 'height', 'src'],
          'td'     => ['colspan', 'rowspan'],
          'th'     => ['colspan', 'rowspan']
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
        transformers: transformers
      }
    end

    # Return a regular expression that will be matched against an embedded IFRAME's
    # source URL's host. If the expression matches, the IFRAME tag will be whitelisted
    # in its entirety; otherwise, it will be sanitized.
    #
    # By default, all hosts are allowed. Override this method if this is not what
    # you want.
    #
    def allowed_iframe_hosts
      /.*/
    end

    # A list of sanitize transformers to be applied to the markup that is to be
    # sanitized. By default, we're only using +embed_transformer+.
    #
    def transformers
      [embed_transformer]
    end

    # A sanitize transformer that will check the document for IFRAME tags and
    # validate them against +allowed_iframe_hosts+.
    #
    def embed_transformer
      lambda do |env|
        node      = env[:node]
        node_name = env[:node_name]

        # We're fine with a bunch of stuff -- but not <iframe> and <embed> tags.
        return if env[:is_whitelisted] || !env[:node].element?
        return unless %w[iframe embed].include? env[:node_name]

        # We're dealing with an <iframe> or <embed> tag! Let's check its src attribute.
        # If its host name matches our regular expression, we can whitelist it.
        uri = URI(env[:node]['src'])
        return unless uri.host =~ allowed_iframe_hosts

        Sanitize.clean_node!(node, {
          elements: %w[iframe embed],
          attributes: {
            all: %w[allowfullscreen frameborder height src width]
          }
        })

        { node_whitelist: [node] }
      end
    end

  private

    # Applies a conversion of the current text state.
    #
    def convert(&blk)
      @current = blk.call(@current)
      self
    end
  end
end

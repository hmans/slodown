module Slodown
  # This is the base Formatter class provided by Slodown. It works right
  # out of the box if you want to use exactly the functionality provided by
  # it, but in most projects, you'll probably want to create a new class
  # inheriting from this one.
  #
  class Formatter
    def initialize(source)
      @current = @source = source.to_s
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

    # Return a hash with the extracted metadata
    #
    def metadata
      @metadata
    end

    def to_s
      @current
    end

  private

    # Applies a conversion of the current text state.
    #
    def convert(&blk)
      @current = blk.call(@current)
      self
    end

    def kramdown_options
      {
        syntax_highlighter: 'coderay',
        syntax_highlighter_opts: {
        }
      }
    end

    def sanitize_config
      {
        elements: %w(
          p br a span sub sup strong em div hr abbr s
          ul ol li
          blockquote pre code kbd
          h1 h2 h3 h4 h5 h6
          img object param del
        ),
        attributes: {
          :all     => ['class', 'style', 'title', 'id'],
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
        transformers: EmbedTransformer.new(allowed_iframe_hosts: allowed_iframe_hosts)
      }
    end

    def allowed_iframe_hosts
      # By default, allow everything. Override this to return a regular expression
      # that will be matched against the iframe/embed's src URL's host.
      /.*/
    end
  end
end

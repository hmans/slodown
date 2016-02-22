module Slodown
  class EmbedTransformer
    attr_reader :opts

    def initialize(opts)
      @opts = opts
    end

    def call(env)
      node      = env[:node]
      node_name = env[:node_name]

      # We're fine with a bunch of stuff -- but not <iframe> and <embed> tags.
      return if env[:is_whitelisted] || !env[:node].element?
      return unless %w[iframe embed].include? env[:node_name]

      # We're dealing with an <iframe> or <embed> tag! Let's check its src attribute.
      # If its host name matches our regular expression, we can whitelist it.
      uri = URI(env[:node]['src'])
      return unless uri.host =~ opts[:allowed_iframe_hosts]

      Sanitize.clean_node!(node, {
        elements: %w[iframe embed],
        attributes: {
          all: %w[allowfullscreen frameborder height src width]
        }
      })

      { node_whitelist: [node] }
    end
  end
end

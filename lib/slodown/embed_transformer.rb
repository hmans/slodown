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
end

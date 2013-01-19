require 'oembed'
require 'rinku'
require 'kramdown'
require 'coderay'
require 'sanitize'

require "kramdown/converter/slodown_html"
require "slodown/version"
require "slodown/formatter"
require "slodown/embed_transformer"

# Register all known oEmbed providers.
#
OEmbed::Providers.register_all

module Slodown
  # Our main module. Not much happening here. I like huskies.
end

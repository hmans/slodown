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

# Register our custom Twitter oEmbed provider. Note that it
# uses Twitter's v1 API, which is marked as deprecated and is said
# to be shut down by March 2013. Twitter's new v1.1 API has an
# oEmbed endpoint, too, but sadly it requires oAuth authentication,
# which doesn't make a lot of sense, but that's that.
#
# Also please note that your application will need to load Twitter's
# //platform.twitter.com/widgets.js in order for these embeds to work.
#
TwitterProvider = OEmbed::Provider.new("https://api.twitter.com/1/statuses/oembed.json?omit_script=true", :json)
TwitterProvider << "http://*.twitter.com/*"
TwitterProvider << "https://*.twitter.com/*"
OEmbed::Providers.register(TwitterProvider)

module Slodown
  # Our main module. Not much happening here. I like huskies.
end

![slodown](https://dl.dropbox.com/u/7288/hendrik.mans.de/slodown.png)

# slodown is the ultimate user input rendering pipeline.

[![Build Status](https://travis-ci.org/hmans/slodown.png?branch=master)](https://travis-ci.org/hmans/slodown) [![Gem Version](https://badge.fury.io/rb/slodown.png)](http://badge.fury.io/rb/slodown)

**I love Markdown. I love syntax highlighting. I love oEmbed. And last but not least, I love whitelist-based HTML sanitizing. slodown rolls all of these into one, and then some.**

Here's what slodown does by default:

- **render extended Markdown into HTML**. It uses the [kramdown](http://kramdown.rubyforge.org/) library, so yes, footnotes are supported!
- **adds syntax highlighting to Markdown code blocks** through [CodeRay](http://coderay.rubychan.de/).
- **supports super-easy rich media embeds**, [sloblog.io-style](http://sloblog.io/~hmans/qhdsk2SMoAU). Just point the Markdown image syntax at, say, a Youtube video, and slodown will fetch the complete embed code through the magic of [ruby-oembed](https://github.com/judofyr/ruby-oembed).
- **auto-link contained URLs** using [Rinku](https://github.com/vmg/rinku), which is smart enough to not auto-link URLs contained in, say, code blocks.
- **sanitize the generated HTML** using the white-list based [sanitize](https://github.com/rgrove/sanitize) gem.

slodown is an extraction from [sloblog.io](http://sloblog.io). It is very easy to extend or modify, as it's just a plain old Ruby class you can inherit from.


## Installation

Add this line to your application's Gemfile:

    gem 'slodown'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slodown

## Usage

For every piece of user input that needs to be rendered, create an instance of `Slodown::Formatter` with the source text and use it to perform some or all transformations on it. Finally, call `#to_s` to get the rendered output.

### Examples:

~~~ruby
# let's create an instance to work with
formatter = Slodown::Formatter.new(text)

# just render Markdown to HTML
formatter.markdown.to_s

# just auto-link contained URLs
formatter.autolink.to_s

# just sanitize HTML tags
formatter.sanitize.to_s

# you can chain multiple operations
formatter.markdown.sanitize.to_s

# this is the whole deal:
formatter.markdown.autolink.sanitize.to_s

# which is the same as:
formatter.complete.to_s
~~~

## Hints

* If you want to add more transformations or change the behavior of the `#complete` method, just subclass `Slodown::Formatter` and go wild. :-)
* Markdown transformations, HTML sanitizing, oEmbed handshakes and other operations are pretty expensive operations. For sake of performance (and stability), it is recommended that you cache the generated output in some manner.
* Eat more Schnitzel.

## TODOs

- More/better specs. slodown doesn't have a lot of functionality of its own, passing most of its duties over to the beautiful rendering gems it uses, but I'm sure there's still an opportunity or two for it to break, so, yeah, I should be adding _some_ specs.
- Better configuration for the HTML sanitizer. Right now, in order to change the sanitizing behavior, you'll need to inherit a new class from `Slodown::Formatter` and override its `#sanitize_config` method. Regarding the contents of the hash this method returns, please refer to the [sanitize documentation](https://github.com/rgrove/sanitize#custom-configuration).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

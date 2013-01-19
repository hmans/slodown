# Slodown: the ultimate user input rendering pipeline.

I love Markdown. I love syntax highlighting. I love oEmbed. And last but not least, I love whitelist-based HTML sanitizing. **Slodown** rolls all of these into one, and then some.

## Installation

Add this line to your application's Gemfile:

    gem 'slodown'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slodown

## Usage

For every piece of user input that needs to be rendered, create an instance of `Slodown::Formatter` with the source text and use it to perform one or all transformations on it. Finally, call `#to_s` to get the rendered output.

Examples:

~~~ruby
# let's create an instance to work with
formatter = Slodown::Formatter.new(text)

# just markdown
@formatter.markdown.to_s

# just HTML tag sanitizing
@formatter.sanitize.to_s

# you can chain multiple operations
@formatter.markdown.sanitize.to_s

# this is the whole deal:
@formatter.markdown.autolink.sanitize.to_s

# which is the same as:
@formatter.complete.to_s
~~~

If you want to add more transformations or change the behavior of the `#complete` method, just subclass `Slodown::Formatter` and go wild. :-)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

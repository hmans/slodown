![Slodown](https://dl.dropbox.com/u/7288/hendrik.mans.de/slodown.png)

# Slodown is the ultimate user input rendering pipeline.

[![Build Status](https://travis-ci.org/hmans/slodown.png?branch=master)](https://travis-ci.org/hmans/slodown) [![Gem Version](https://badge.fury.io/rb/slodown.png)](http://badge.fury.io/rb/slodown)

**I love Markdown. I love syntax highlighting. I love oEmbed. And last but not least, I love whitelist-based HTML sanitizing. Slodown rolls all of these into one, and then some.**

Here's what Slodown does by default:

- **render extended Markdown into HTML**. It uses the [kramdown](http://kramdown.gettalong.org/) library, so yes, footnotes are supported!
- **add syntax highlighting to Markdown code blocks** through [CodeRay](http://coderay.rubychan.de/), [Rouge](http://rouge.jneen.net/), or any other highlighter supported by kramdown.
- **support super-easy rich media embeds**. Just point the Markdown image syntax at, say, a Youtube video, and Slodown will fetch the complete embed code through the magic of [ruby-oembed](https://github.com/judofyr/ruby-oembed).
- **auto-link contained URLs** using [Rinku](https://github.com/vmg/rinku), which is smart enough to not auto-link URLs contained in, say, code blocks.
- **sanitize the generated HTML** using the white-list based [sanitize](https://github.com/rgrove/sanitize) gem, with some really good default configuration.

Slodown is an extraction from [sloblog.io](http://sloblog.io). It is very easy to extend or modify, as it's just a plain old Ruby class you can inherit from.

## General Approach

Slodown, out of the box, implements my preferred way of handling user input, which looks like this:

- Convert all Markdown to HTML.
- Don't strip HTML the user added themselves.
- Auto-link contained URLs and email addresses.
- Finally, and most importantly, run the entire HTML through a really, really good whitelist-based sanitizer.

This allows users to still add their own HTML, if required. In fact, I typically encourage users to make use of [kramdown's inline attributes](http://kramdown.gettalong.org/syntax.html#inline-attribute-lists), leaving it up the sanitizer to make sure they don't go crazy.

If this is not what you want, you will most likely be able to bend Slodown to your will -- it's pretty flexible.


## Usage

For every piece of user input that needs to be rendered, create an instance of `Slodown::Formatter` with the source text and use it to perform some or all transformations on it. Finally, call `#to_s` to get the rendered output.

### Examples:

~~~ruby
# let's create an instance to work with
formatter = Slodown::Formatter.new(text)

# just extract metadata
formatter.extract_metadata.to_s

# just render Markdown to HTML
formatter.markdown.to_s

# just auto-link contained URLs
formatter.autolink.to_s

# just sanitize HTML tags
formatter.sanitize.to_s

# you can chain multiple operations
formatter.markdown.sanitize.to_s

# this is the whole deal:
formatter.extract_metadata.markdown.autolink.sanitize.to_s

# which is the same as:
formatter.complete.to_s
~~~

If you want to customize Slodown's default behavior, simply create a new class that inherits from `Slodown::Formatter` and override methods like `#kramdown_options`, or add your own behaviors.


## Syntax Highlighting

Just add [CodeRay](http://coderay.rubychan.de/) or [Rouge](http://rouge.jneen.net/) to your project to have code blocks in your Markdown syntax-highlighted. Slodown will try to detect which library you're using, but to be sure, change your `kramdown_options` accordingly. For example:

~~~ ruby
class Formatter < Slodown::Formatter
  def kramdown_options
    {
      syntax_highlighter: 'coderay',
      syntax_highlighter_opts: { css: :class }
    }
  end
end
~~~


## oEmbed support

> oEmbed is a format for allowing an embedded representation of a URL on third party sites. The simple API allows a website to display embedded content (such as photos or videos) when a user posts a link to that resource, without having to parse the resource directly.

Slodown extends the Markdown image syntax to support oEmbed-based embeds.
Anything supported by the great [oEmbed gem](https://github.com/judofyr/ruby-oembed) will work. Just supply the URL:

~~~markdown
![youtube video](https://www.youtube.com/watch?v=oHg5SJYRHA0)
~~~

**Note on IFRAMEs:** Some oEmbed providers will return IFRAME-based embeds. If you want to control
which hosts are allowed to have IFRAMEs on your site, override the `Formatter#allowed_iframe_hosts` method to return a regular expression that will be matched against the IFRAME source URL's host. Please note that this will also apply to
IFRAME HTML tags added by the user directly.

**Note on Twitter:** Twitter's oEmbed endpoint will return a simple bit of markup that works okay out of the box, but can be expanded into a full tweet view client-side. For this to work, you'll want to add Twitter's [widget.js](http://platform.twitter.com/widgets.js) to your application. Please refer to the [Twitter documentation](https://dev.twitter.com/web/javascript) for full instructions.


### Metadata

Slodown allows metadata, such as the creation date, to be defined in the text to be processed:

~~~markdown
#+title: Slodown
#+created_at: 2014-03-01 13:51:12 CET
# Installation

Add this line to your application's Gemfile:

    gem 'slodown'

...
~~~

Metadata can be accessed with `Slodown::Formatter#metadata`:

~~~ruby
formatter.metadata[:title] # => "Slodown"
~~~


## Hints

* If you want to add more transformations or change the behavior of the `#complete` method, just subclass `Slodown::Formatter` and go wild. :-)
* Markdown transformations, HTML sanitizing, oEmbed handshakes and other operations are pretty expensive operations. For sake of performance (and stability), it is recommended that you cache the generated output in some manner.
* Eat more Schnitzel. It's good for you.

## TODOs

- More/better specs. Slodown doesn't have a lot of functionality of its own, passing most of its duties over to the beautiful rendering gems it uses, but I'm sure there's still an opportunity or two for it to break, so, yeah, I should be adding _some_ specs.
- Better configuration for the HTML sanitizer. Right now, in order to change the sanitizing behavior, you'll need to inherit a new class from `Slodown::Formatter` and override its `#sanitize_config` method. Regarding the contents of the hash this method returns, please refer to the [sanitize documentation](https://github.com/rgrove/sanitize#custom-configuration).

## Contributing

Just like with my other gems, I am trying to keep Slodown as sane (and small) as possible. If you
want to contribute code, **please talk to me before writing a patch or submitting
a pull request**! I'm serious about keeping things focused and would hate to cause
unnecessary disappointment. Thank you.

If you're still set on submitting a pull request, please consider the following:

1. Create your pull request from a _feature branch_.
2. The pull request must only contain changes _related to the feature_.
3. Please include specs where it makes sense.
4. Absolutely _no_ version bumps or similar.

## Version History

### 0.4.0 (2017-01-13)

- Feature: Block-level images are now rendered as a complete `<figure>` structure (with optional `<figcaption>`.)
- Change: The Slodown sanitizer now allows `<figure>`, `<figcaption>`, `<cite>`, `<mark>`, `<del>` and `<ins>` tags by default.
- Change: The Slodown sanitizer was stripping HTML of table tags. Tables are harmless, so they're not being stripped any longer.

### 0.3.0 (2016-02-22)

- Removed the dependency on CodeRay. If you want syntax highlighting in your Markdown parsing, simply add CodeRay (or Rouge, or any other highlighter supported by kramdown) to your project.

### 0.2.0 (2016-02-22)

- Slodown is now whitelisting all domains for possible iframe/embed-based media embeds by default. If you don't want this, you can override `Formatter#allowed_iframe_hosts` to return a regular expression that will match against the embed URL's host.
- Bumped minimum required version of kramdown to 1.5.0 for all the nice new syntax highlighter integrations it offers (and changes required due to deprecated/changed options.)
- Support for Twitter oEmbed (using an unfortunately deprecated API, nonetheless.)
- Added `Slodown::Formatter#kramdown_options`, returning a hash of kramdown configuration options. Overload this in order to customize the formatter's behavior.

### 0.1.3

- first public release

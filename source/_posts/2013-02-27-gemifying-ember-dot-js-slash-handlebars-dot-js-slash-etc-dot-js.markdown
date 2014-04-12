---
layout: post
title: "Slaying the Ember/Handlebars JS-RB Dependency Demons with Gem Wrappers"
date: 2013-02-27 23:28
comments: true
categories: 
- ember-source
- handlebars-source
- emblem-source
- gemifying
---

Ember.js devotees may have noticed a series of related commits that I
put in recently with reference to "removing vendored .js files in favor
of ember-source, handlebars-source, etc", or something of the like.
They're all checked in now, and I think they've gone a long way towards
alleviating the dependency hell stemming from multiple gems packaging
vendored .js files. 

For a better understanding of the motivation behind these
changes and how they might affect you, read on.

<!--more-->

## The Problem

You're using `ember-rails` to build an Ember v1.0.0.pre4 app hosted by your Rails
server. Your Handlebars (or [Emblem](http://emblemjs.com)) templates are
being precompiled by the [barber gem](https://github.com/tchak/barber)
used by `ember-rails`, which uses Handlebars.js rc2.

You wisely decide to upgrade to Ember v1.0.0.rc1, only to find that
Ember rc1 now depends on Handlebars rc3 (instead of rc2). Even though
you've overridden `ember-rails` to serve the latest Ember and Handlebars
to the browser, the `barber` gem is still using its Handlebars rc2 to
compile your templates, and when you run your app, you're greeted with
the following error.

```
Ember Handlebars requires Handlebars 1.0.0-rc.3 or greater
```

You hurriedly submit a pull request to `barber` with a freshly bundled
handlebars rc3 along with 8 other people, but Parisian Paul won't be 
awake for another 8 hours to merge the PR, so you duck-punch your way to
temporary solution, cluttering your app with its very own vendored
Handlebars.js.  

The situation normalizes in a few days, only to repeat itself for the
next backwards-incompatible version bump. 

## Lightweight Gem Wrappers around JS Libs

To prevent this sort of thing from happening in the future, there's a
now a lightweight gem wrapper for the following:

- [handlebars-source](https://rubygems.org/gems/handlebars-source)
- [ember-source](https://rubygems.org/gems/ember-source)
- [ember-data-source](https://rubygems.org/gems/ember-data-source)
- [emblem-source](https://rubygems.org/gems/emblem-source)

These gems contain nothing more than .js files and just enough Ruby code
to help you determine an absolute path to the .js file contained within
the gem. Example:

{% codeblock lang:ruby %}
{% raw %}
require 'handlebars/source'

context = ExecJS.compile(File.read(Handlebars::Source.bundled_path))
puts context.call 'Handlebars.precompile', '{{hello}}'

# =>
# function (Handlebars,depth0,helpers,partials,data) {
#   this.compilerInfo = [2,'>= 1.0.0-rc.3'];
#   helpers = helpers || Handlebars.helpers; data = data || {};
#   var stack1, functionType="function", escapeExpression=this.escapeExpression;
# 
#   if (stack1 = helpers.hello) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
#   else { stack1 = depth0.hello; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
#   return escapeExpression(stack1);
#   }
{% endraw %}
{% endcodeblock %}

At the time of writing, most of the gems you'd ever use for your Ember
projects use these gems, and since they don't specify dependencies upon
any particular versions of these gems, the app using these gems has full
control over which versions of the JS libs these gems will use for
precompiling, asset packaging, etc. 

So, coming back to the dependency hell scenario above, if you're writing
an app in Ember rc1, and Ember rc2 comes out with a dependency on a
new, backwards incompatible Handlebars, all you have to do to upgrade to
the latest Ember/Handlebars and have your precompilation /
asset-packaging libs do the same is put the following in your Gemfile:

```
gem 'ember-source', '1.0.0.rc2'
```

And run `bundle update ember-source`. `ember-source` has a dependency on
a particularly version range of `handlebars-source`, so that'll be
updated to an appropriate version as well, and all the gems that use
`ember-source` and `handlebars-source` will magically start using the
new .js files. 

## Caveat

The versions chosen for the `____-source` gems match as closely as possible
the current version of the bundled JS lib. The only problem with this is
that the latest Ember and Handlebars versions are release candidates,
and the letters in the versions (e.g. `1.0.0.rc1`) trigger special
(annoying) pre-release version resolution logic for both RubyGems and
Bundler.  All this means is that you have to be very specific about 
the version of `____-source` you want to use, and you won't be able to
use the pessimistic `~>` version operator, since that'll kick out to the
nearest non-pre-release version of the gem it can find, rather than
staying within the bounds of an `rc` sub-version. So, TL;DR, do the
following:

{% codeblock lang:ruby %}
# Gemfile
gem 'ember-source', '1.0.0.rc1.2'

# This won't work.
# gem 'ember-source', '~> 1.0.0.rc1.0'
{% endcodeblock %}

## Appendix: Getting the .js files out of the `___-source` gems

Handlebars:

{% codeblock lang:ruby %}
# Gemfile
gem 'handlebars-source'

# Code
require 'handlebars/source'
Handlebars::Source.bundled_path # => "/Users/.../handlebars.js"
Handlebars::Source.runtime_bundled_path # => "/Users/.../handlebars.runtime.js"
{% endcodeblock %}

Ember / Ember Data:

{% codeblock lang:ruby %}
# Gemfile
gem 'ember-source'
gem 'ember-data-source'

# Code
require 'ember/source'
require 'ember/data/source'
Ember::Source.bundled_path_for("ember.js") # => "/Users/.../ember.js"
Ember::Data::Source.bundled_path_for("ember-data.js") # => "/Users/.../ember-data.js"
{% endcodeblock %}







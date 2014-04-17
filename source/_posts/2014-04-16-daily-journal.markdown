---
layout: post
title: "Daily Journal"
date: 2014-04-16 13:31
comments: true
categories: 
---

### Heroku + Unicorn + Rails Logging

We're using Unicorn on Heroku and would like to log just about
everything, particularly incoming JSON request payloads, but it seemed
like the Heroku logs (which we forward to Papertrail) weren't properly
logging everything the way they do with `rails server`.
[This article](http://dave.is/unicorn.html) points out the problem and
offers the solution; specifically, `rails s` adds
`Rails::Rack::LogTailer` middleware which tails the log files and prints
their contents to `stdout`, but if you run your server via `unicorn`,
that middleware doesn't get added, so if you want a Unicorn-driven Rails
server to have the same logging behavior as `rails s`, you'll have to 
configure the Rails logger to print to STDOUT in
`config/application.rb`:

    config.logger = Logger.new(STDOUT)
    config.logger.level = Logger.const_get(
      ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].upcase : 'DEBUG'
    )

### Prevent expensive debug logs

This is coming from an old ass Railscast, but thought it was cool: if
you do `logger.debug "some #{expensive_calc}"`, it'll only print this
out if your log level is `:debug`, but the `expensive_calc` is still
performed; to actually prevent the calculation unless you're on
`:debug`, you can write this as:

    logger.debug { "some #{expensive_calc}" }

### `Hash#values_at`

In Ruby, use `Hash#values_at` to query a Hash for multiple and return an
array of those values, e.g.

    hash = { some: "value", other: "lame value" }
    hash.values_at(:some, :other) # => ["value", "lame value"]

This plays nicely with multiple assignment:

    some,other = hash.values_at(:some, :other)
    # now some and other have been assigned values from the hash

This is the Ruby equivalent of `Ember.getProperties(obj, vals)`.



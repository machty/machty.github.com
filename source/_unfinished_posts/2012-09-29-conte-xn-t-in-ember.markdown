---
layout: post
title: "Conte[xn]t in Ember"
date: 2012-09-29 13:00
comments: true
categories: ember.js, context, content, templates
---
One of the many bricks in Ember.js's wall of a learning curve is the
blurring of definitions between the two related terms `content` and
`context`, both of which will show up while you're building out your
Ember apps. To this day I still stumble over the two definitions and
where one ends and the other begins, and I figured I'd write this to
settle the confusion once and for all.

<!--more-->

## Why are we talking about this?

Because Ember's learning curve is legendarily steep and the codebase
has been racing for months towards a 1.0 that documentation hasn't
really had time to catch up. When you're already trying to reconcile
Ember's particular take on the definition of `controller` with what you
might know about Rails or some other MVC framework, to have these two
terms `conte[xn]t` come along that are _one letter apart_ and often pop
up in the same (forgive me) contexts, that brick wall learning curve
actually starts to tip in your direction.

The cool thing about Ember (and Rails, and any other hyper-opinionated
framework) is that if you've organized everything correctly and chosen
the correct data structures, you really do end up with a small amount of
code that still manages to be flexible and extensible, but you still
need to have a pretty solid understanding of how all the data gets tied
together. So, on to `conte[xn]t`.

### Context

Loosely taken from Emberjs.com:

> **context**: an object on which properties are looked up.

Accurate, all-encompassing, but not entirely helpful. I would refine as
follows:

> **context**: the object whose properties are used to fill in the
> blanks in a template.

So basically, if you're not talking about templates, _don't use the
word `context`_! You will only confuse yourself.

#### But wait...

Doesn't Ember use the word `context` in other settings, and not just
when dealing with templates? Yes, particularly in the source code, but
you'll drive yourself crazy trying to keep that all together when all
you should really be caring about is how to churn out tons of templates
and views harmoniously linked together with a minimal amount of code
without thinking twice about whether it's `context` or `content` that
you're supposed to be using. So, with the in mind, I will restate that

**`context` is an object whose properties are used to fill in the blanks of a
template**, and unless you're talking about templates and Views, you
shouldn't be throwing the word `context` around (unless you like
confusing yourself and others).

#### `context` in Templates

So let's look at some templates.

{% codeblock %}
{% endcodeblock %}

### Content

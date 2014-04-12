---
layout: post
title: "May You Never Be Confused by Ember.js Templates Ever Again"
date: 2012-11-30 18:18
comments: true
categories: 
- ember.js
- context
- content
- templates
---
Here's a billion different ways you can tie your data to Ember
templates. I intend for this to be helpful to both Ember noobs and
seasoned vets as this is something I've had trouble with from the
beginning that I've continued to occasionally stumble over.

<!-- more -->

## A Note on Conte[xn]t.

_Skip to the bottom if you already understand this stuff, but it's worth
a read if you're like me and still stumble on it from time to time._

I'd actually intended to write a giant article on difference between the
terms `context` and `content`, both of which seem to pop up when dealing
with views and templates, and given their mere _single-letter
distinction_ and their conceptual overlap, it's definitely something I
struggled with greatly. So, let's nip that in the bud from the beginning
before digging into the examples.

### Context, with an _X_

A definition to live by:

> **context**: the object whose properties are used to fill in the
> blanks in a template.

Yes, there are some occasional instances in every day Ember App
development and in the Ember source code itself where the term `context`
is used to describe something else, but this definition should cover
your bases for the most part while you grok Ember views and templates.

A `context` object can just be
[a hard-wired JavaScript object](http://jsfiddle.net/machty/mteRN) or
[an Ember.Object](http://jsfiddle.net/machty/ZqCwZ), but this guide will
help to demonstrate some patterns you can use that don't involve
explicitly setting the `context` property on a View.

### Content, with an _N_

So, if you know what an Ember.View's context property evaluates to, you
know exactly what object will be used to fill in the blanks on a
template. So where does the term `content` come in? 

If you have a glance at the Ember source code (which I always have open
in another panel to resolve these kinds of confusions while Ember still
remains in a relatively undocumented state as it races to v1) for
`Ember.View` and search for `content`, the only code you'll find that
deals with `content` is a convenience function called `contentView`,
which returns the nearest parent view that has the property `content`
defined. Other than that there's nothing special or semantic or required
or depended on about the property `content` if you're just dealing with
a normal vanilla `Ember.View`. But the term `content` _does_ start to
pop up if you look at `Ember.CollectionView`

#### Content in Ember.CollectionView

An `Ember.CollectionView` is a subclass of `Ember.View` that creates a
child view for every element in an underlying array. So if you had a
list of dogs and wanted to display a DogView for each dog in the array,
you could use a collection view for that. 

Back to `context`s: keeping in mind that a `context` is an object to
fill in the blanks of a View's template, would you expect to find the
term `context` anywhere in the source code for `Ember.CollectionView`?
The answer is no, because a `CollectionView` doesn't use a template at
all -- the only thing it displays are child views based on the items in
its underlying array. So, `context` is out, but what do we use to refer
to that underlying array that the `CollectionView` manages and displays
views for? You guessed it: `content`.

A `CollectionView`'s underlying array is stored in its `content`
property. It will construct a child view for every element in this
`content` array, and will in turn set the `content` property of each
generated child view to the corresponding element in the array. But but
but, and this tripped me up a million times, this `content` property on
the child view will not on its own be used to fill in the blanks of the
child view's template. Why? Because `content` != `context`, and
remember that it's always the `context` (with an X) property that
determines the values that'll be used to fill in the blanks of a template.

If this is news to you, meditate on that for a while, and never forget
it. It'll save you hours of toil and confusion. If you're having trouble
getting values to show up in your templates, it almost always means that
your `context` property on the view isn't set to what you think it is,
and not some other weird glitch.

Note that `content` will show up in other cases, but if you keep in mind
the principles above, you should be able to avoid a lot of confusion.

#### Content in ObjectProxy and ArrayProxy

There's one other important, common pattern you'll run into involving
the term `content`, and that's with `Ember.ObjectProxy` and
`Ember.ArrayProxy`. If you're new to Ember, you might be thinking,
"Boy Howdy, another brick in the wall of the seemingly vertical learning curve."
Fortunately, `[Object|Array]Proxy`'s are the easiest of concepts to
understand.

An `ObjectProxy` is just an `Ember.Object` with one magical feature: if
you set the `content` property of an `ObjectProxy`, then any properties
you try to look up on the `ObjectProxy` that don't exist will, instead
of just immediately returning undefined, be looked up on the `content`
object of that object proxy. Example!

{% codeblock lang:javascript %}

var obj = { foo: 5 };
var objProxy = Ember.ObjectProxy.create({
  content: obj 
});

objProxy.get('foo'); // 5
{% endcodeblock %}

In this example, Ember will try to look up the property `foo` on the
objProxy, and since no such property exists, it'll look up the `foo`
property on `obj` since that's specified as the `content` property on
the `ObjectProxy`.

## Handlebars Basics

Please re-read 
[Handlebars Basics](http://emberjs.com/documentation/#toc_handlebars-basics)
from the EmberJS.com docs if you're still unfamiliar with the basics of
how to get data into your templates. I'm mostly just trying to cover all
of the tricky gotchas rather than the basics here. The most important
thing to remember is that, by default, the blanks in a template will be 
filled by the properties on the `context` object specified by the View, unless:

1. The property starts with a capital letter, e.g. `App.foo`, in which
   case it'll fill in the blanks with the `foo` property from the global
   variable `App`
1. The property starts with `view.`, e.g. `view.foo`, which will fill in
   the blanks with the `foo` property on the View.

## Debugging Templates

With the above in mind, here's a few things you can try if you're having
trouble getting data to show up in your templates:

### \{\{debugger}}

You can use the Handlebars `debugger` helper to stop your browser
debugger right in the middle of rendering the template. While stopped in
this location, the `this` keyword refers to `context` object
(dare I say it once more: the object used to fill in the blanks of the
template). You can evaluate properties on the context object while in
the debugger via `this.get('foo')` or `this.foo` (if it's a raw JS object).
To find out what type of object it is, you can evaluate
`this.constructor` in the debugger and it'll print out something useful
like `App.User` or `Ember.Object`.

### \{\{view.context.constructor}}

Arguably a less sophisticated approach, you can also just print (into
the DOM) the type of the context object using `view.context.constructor`
in your template. This is a quick, lazy way of verifying that at the
very least, the context object is the type you expect. If you're
expecting your context object to be an `App.User` and this trick
reveals that it's an `Ember.View`, you'll know that you probably
incorrectly set your context object. But, why not just use the debugger
as recommended above and query the `this` keyword?



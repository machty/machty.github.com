---
layout: post
title: "Daily Journal"
date: 2014-05-19 07:38
comments: true
categories: 
- use strict
- global id
---

## Active Model: GlobalID

https://github.com/rails/activemodel-globalid/

GlobalID is a way of serializing a model into a string so that
it can be looked up later; rather than serializing all of the
object's data into a string, you merely serialize just enough 
information so that you can look up the rest.

I'm already doing something similar with model dep state in Ember,
only extending it such that part of the "GlobalID", which we'll
use internally for binding into a cache bucket, might be a prefixing
controller name to uniquely identify a cache bucket to a specific
controller, but in cases where you want to share information about
a model with other controllers, you'd leave this prefix off.

Anyway, nice to see other folk arriving at a similar thing, though
I personally wouldn't call this sort of thing "serializing" but rather
"paramaterizing", since you're not actually storing all the data in
string form but just enough to uniquely identify it so that some
other operation can restore the object.

## Strings have read-only props in "use strict" Safari

The following throws an exception only in Safari (not Chrome or FF):

    (function(){"use strict"; ("a").b = 'writing to a string'; })();
    TypeError: Attempted to assign to readonly property.

But not if you leave off the "use strict".







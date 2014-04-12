---
layout: post
title: "Stubbing Date::valueOf for Benefit of Make Great Good Determinism"
date: 2013-03-24 13:20
comments: true
categories: 
- JavaScript
- testing
- valueOf
- determinism
---

Quick thing: if you ever find yourself in the situation of writing
JavaScript test cases that involve `setTimeout` or some other timer
logic where the order of timers firing is the subject of testing, you
might find this trick handy to get rid of brittle, non-deterministic
test cases. 

In short, you can stub out the `Date` class's `valueOf` method to return
a value you expect for the duration of the test case.

<!-- more -->

## The Problem

I recently did some work on Ember.js's run loop, particularly improving
a few oddities about `Ember.run.later`, and adding better coverage to
their run loop test suite. But we were noticing that one of my test
cases would very occasionally fail, most often when the testing
workstation was under heavy computational load. The problem, boiled down
to its essence, was that I'd made the poor assumption that consecutive
calls to `+ new Date()`, a shorthand for returning the number of
milliseconds from 1970, would return the same value.

```javascript
+ new Date(); // 123456788
+ new Date(); // 123456788
+ new Date(); // 123456788
+ new Date(); // 123456789 <-- boom
```

Duh, right? Time does have a weird OCD habit of elapsing, but I needed,
for the assumptions of 
[this particular test](https://github.com/emberjs/ember.js/blob/master/packages/ember-metal/tests/run_loop/later_test.js#L114), 
the JavaScript clock to return the same value for consecutive calls to
`+ new Date`.

## `Date::valueOf`

Turns out that the function ultimately called when using the `+ new Date`
shorthand is the `valueOf` function on the `Date` class. That's where
the numeric millisecond return value comes from.

The solution to the test case's brittleness was to force all the
consecutively-run timer-dependent code to all get the same numeric
millisecond value from their own internal calls to `+ new Date`. To do
this, I stubbed the `valueOf` function as follows:

```javascript
var now = + new Date(); // 123456788
var originalDateValueOf = Date.prototype.valueOf;
Date.prototype.valueOf = function() { return now };
+ new Date(); // 123456788
+ new Date(); // 123456788
+ new Date(); // 123456788
+ new Date(); // 123456788
+ new Date(); // 123456788
+ new Date(); // 123456788

// ... it will continue to return this value until
// I return `valueOf` back to its original native function.
Date.prototype.valueOf = originalDateValueOf;

+ new Date(); // 123456789
```

So, there you have it when you need it; stubbed determinism when futzing
with JavaScript timers.
[Here's](https://github.com/emberjs/ember.js/pull/2341/files) how it
looked in the fixed Ember.js run loop test case.

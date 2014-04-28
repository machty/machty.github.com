---
layout: post
title: "Daily Journal"
date: 2014-04-26 14:49
comments: true
categories: 
---

## JavaScript: `Object#constructor`

    function A() {}
    function B() {}
    B.prototype = Object.create(A.prototype);
    console.log(new B().constructor); // "[Function: A]"

That's not what we want. If we use `Object.create` on a parent class's
prototype, you need to also do

    B.prototype.constructor = B;
    console.log(new B().constructor); // "[Function: B]"

TL;DR, you must manually set `constructor` on a subclass's prototype to
point to that subclass's constructor function, or else `.constructor`
will refer to a parent class's constructor.

## Duck duck go

Search engine that I should be using.

## `tree` 

`tree` is a command you can install with `brew install tree` that
gives you a visual, recursive display of a folder. Output looks like
this:

    app/routes
    ├── ad.js
    ├── application.js
    ├── builds
    │   ├── form.js
    │   ├── index.js
    │   ├── select
    │   │   └── index.js
    │   └── select.js




---
layout: post
title: "Daily Journal"
date: 2014-05-22 14:08
comments: true
categories: 
- Array Computed / Reduce Computed
flashcards:
- front: "What's the difference between array and reduce computed properties?"
  back: "Reduce CPs can reduce to anything you want, either a single value or an array. Array CPs are instances of reduce CPs that always return arrays."
---

## Array Computed / Reduce Computed

The difference between reduce computed properties and array computed
properties in Ember is that reduce computed properties will boil down
the contents of an array to _some value_ using one-at-a-time semantics;
Array CPs are Reduce CPs that happen to boil down to: other arrays.

So you can't write a "sum" Array Computed; you'd just use reduce
computed for that. And you _could_ write your own hand-crafted "filter"
reduced CP, but why not use the Array Computed API for that?




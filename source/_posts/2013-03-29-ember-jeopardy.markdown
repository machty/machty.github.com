---
layout: post
title: "Ember Jeopardy"
date: 2013-03-29 15:36
comments: true
categories: 
- Ember.js
- Jeopardy
- Meetup
---

At last night's [NYC Ember Meetup](http://www.meetup.com/EmberJS-NYC/events/106490682/),
I led the gang through a somewhat enduring session of Jeopardy,
featuring a ton of different Ember.js trivia questions. The app itself
was written in Ember.js and the source code is mostly good, and
certainly well-commented. Have a look see:

[Ember Jeopardy](http://ember-jeopardy.herokuapp.com/)

[Source code](https://github.com/machty/ember-jeopardy)

It's (somewhat needlessly) hosted within a Rails app, but you can find the
Ember-specific code in `app/assets/javascripts/`. It presently only
works on non-retina Safari/Chrome, given all the 3D stuff going on, but
if you can figure out how to slay the remaining CSS3 demons, I'd
definitely appreciate a pull request.


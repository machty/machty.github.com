---
layout: post
title: "Speeding up Firefox CSS3 transform transitions with rotate(0.01deg)"
date: 2012-08-07 02:53
comments: true
categories: 
- Firefox
- CSS3
- transitions
- rotate
---
I'm working on a heavily animated (non-Flash) kids' website and was getting some exceptionally slow performance from Firefox during supposedly GPU-accelerated CSS3 transitions. 

[Turns out there's a bug](https://bugzilla.mozilla.org/show_bug.cgi?id=663776), still unaddressed, that lubricates Gecko with jank molasses anytime it has to animate a transition involving the `scale()` property. The solution? Add a dash of `rotate(0.01deg)` to your `transform` property and the problem magically goes away. Somehow, adding a small degree of unnoticeable rotation renders the transition way more smoothly, and this goes for both CSS3 transitions and animations in Firefox. 

So if you'd like to transition `-moz-transform` to `scale(2)`, set it instead to `scale(2) rotate(0.01deg)` and watch the jank magically disappear.

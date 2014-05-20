---
layout: post
title: "Daily Journal"
date: 2014-05-15 11:38
comments: true
categories:
- Uniform Type Identifiers
---

## Uniform Type Identifiers

Turns out I never understood why Java and other languages/frameworks
embraces this style of "com.domain.somepackage". First off, this is
called [Reverse domain name notation](http://en.wikipedia.org/wiki/Reverse_domain_name_notation).

The purpose of this naming convention is two-fold:

#### Avoids naming collisions from two different vendors

By prefixing the package name with any sort of
unique identifier, "SOME-PREFIX-A.packageName" won't conflict with
"SOME-PREFIX-B.packageName".

#### Sensible sort order / grouping

You want packages from the same
vendor to be grouped together in sensible way; if you use the `apple`
and `carrots` packages from `food.somevendor.com` and the `bikes` package
from `things.somevendor.com`, if you didn't reverse the domain order, you might
end up with the following folder structure

    food/
      somevendor/
        com/
          apple
          carrots
    things/
      somevendor/
        com/
          bikes

This is undesirable since you can't tell from this structure that apple,
bikes, and carrots all come from somevendor. Also, you there's a
needless repetition of the `somevendor/com` path in both directory
trees. If the domain name were inverted, you'd end up with:

    com/
      somevendor/
        food/
          apple
          carrots
        things/
          bikes

Less folders, less repetition, and more information is being conveyed.

Another way to think about it is that domain names are somewhat
backwards; we know that `.com`, `.net`, and 
[`.technology`](http://sandwich.technology) are top-level domains (TLD),
but how/why is something top level appended at the end of a name? It
definitely makes domain names with subdomains harder to sort in a
meaningful way. I guess there's probably a good reason for this, worth
investigating in another journal entry.

Another good/quick SO explanation: http://stackoverflow.com/a/2475191/914123

## LevelDB

- require('leveldbdatabase')
- key value pair
- scales, web scale
- PolicyMic is sponsoring folk to work on it

## Vim: Visual Line

Shift-V in vim goes into visual line mode, which means you select entire
lines for yanking/cutting, rather than having to precisely position your
cursor at the beginning or end of a line so as to not accidentally yank/cut 
only part of a line.














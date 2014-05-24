---
layout: post
title: "Daily Journal"
date: 2014-05-01 08:59
comments: true
categories: 
flashcards:
  - front: "denormalize"
    back: "Adding duplication/redundancy to a system, e.g. storing a person's first name in multiple tables, often for the purpose of optimization"
  - front: "quick way to stub out a Ruby method so that it accepts any number of args"
    back: "def meth(*args)"
  - front: "Fight nils by using this Hash/Array accessor instead"
    back: "Hash#fetch or Array#fetch (note that there is no Enumerable#fetch)"
  - front: "Command to change directories, saving the current location"
    back: "pushd /some/place; popd"
---

## Normalize / Denormalize

From [Wikipedia](http://en.wikipedia.org/wiki/Database_normalization):

Database normalization is the process of organizing the fields and 
tables of a relational database to minimize redundancy.

Source: Gary Bernhardt saying "we denormalize by passing in
`person_name` in addition to the person object". Normalizing means
keeping all the data in one place, reducing redundancy. Denormalizing
means redundancy, which normally affords

[Denormalization](http://en.wikipedia.org/wiki/Denormalization):

> In computing, denormalization is the process of attempting to 
> optimize the read performance of a database by adding redundant
> data or by grouping data. In some cases, denormalization
> is a means of addressing performance or scalability in relational
> database software.

Generally speaking, denormalizing means you've duplicated some piece of
data for some reason, probably optimization.

## Stub a method in ruby

As simple as 

    def stubbed_method(*args)
      # accept any number of args, do nothing with them.
    end

## Use `fetch`, not `[]` for `Hash` / `Array`

I already know this, just keep on forgetting to use it;

    {}[123] # => nil
    {}.fetch(123) # => KeyError: key not found: 123
    
## Directory stack: `pushd` / `popd`

Forgot about this from my Bloomberg days; use `pushd` and `popd` for
saving which directory you're in (`pushd`) so that you can screw around,
change directories, and then ultimately `popd` back to whichever directory
you were in before you ran `pushd`.

    cd /foo/bar/baz
    pushd /some/other/dir
    pwd # => /some/other/dir
    cd /go/to/some/strange/land
    popd
    pwd # => /foo/bar/baz


---
layout: post
title: "Ember CLI and NPM fights"
date: 2014-04-12 18:30
comments: true
categories: 
flashcards:
  - front: What is the name of the latest JS build tool that uses trees as a first class primitive for describing file transformations.
    back:  Broccoli
  - front: Run this command inside a node project folder to install its binaries to your system
    back:  npm link
---

Daily Journal: 4/12/14

I've been giving [ember-cli](https://github.com/stefanpenner/ember-cli)
a whirl the last few days; it's still extremely alpha but it's extremely
cool. It leverages [Broccoli](https://github.com/joliss/broccoli) as a
highly performant build tool, which minimifies the amount of rebuilding
that must occur when a file changes in your project; in this way it's a
major improvement over previous iterations of Ember tooling, such as
[Ember App Kit](https://github.com/stefanpenner/ember-app-kit), which
falls prey to all of the gotchas involved with teaching Grunt, a
JavaScript task runner, to act like a build tool, but because Grunt
doesn't have any built-in primitives for describing/tracking
dependencies between files, or any other primitives convenient for use
as a build tool without a plethora of plugins/addons, it's very 
difficult to arrive at a Grunt setup that:

1. Minimizes rebuilding in response to file changes
2. Has configuration that is easy to reason about
3. Locks your server during rebuilds (so that you're not serving
   files from a half-compiled project folder)

Anyway, onward to stuff I actually learned.

<!-- more -->

### `npm link` to locally develop `ember-cli`

`npm install -g ember-cli` installs `ember-cli` globally so that its
binaries are installed and accessible to the whole system. But what
about if you're contributing to `ember-cli` and want to test the binary
you're actively developing? 

    git clone https://github.com/stefanpenner/ember-cli
    cd ember-cli

    # Point ember-cli binaries to this project folder
    npm link

Now when you run the `ember` command it'll run the code in your local
development `ember-cli`. I verified this by doing 
`git checkout SOME_OLD_TAG` and running `npm link` again, and then
when I ran `ember --version`, it spat out the version I'd just checked
out. Baby stuff, right? Maybe, but I find the node world mysterious and
frightening and this was a nice sanity check. 

Now, if you create a new Ember project via `ember new some-proj`, it may
come as a surprise that `ember-cli` libraries installed in
`some-proj/node_modules` is not the local `ember-cli` that you 
`npm link`'ed; this seems ok to me as a default, but if you also want
your `ember new`-generated project to internally use your local 
`ember-cli` code, `cd` into `some-proj` and then run 
`npm link ember-cli`, which will install symlinks in `node_modules`
pointing `ember-cli` to the same place that your development `ember-cli`
was linked into:

    some-proj:: ls -l node_modules/ember-cli
    lrwxr-xr-x  1 machty  staff  37 Apr 12 17:05 node_modules/ember-cli -> /usr/local/lib/node_modules/ember-cli

I find the overloading of `npm link` here extremely confusing; the
present/absence of the last param to `npm link` causes the command to 
do drastically different things, but maybe that's just me. 


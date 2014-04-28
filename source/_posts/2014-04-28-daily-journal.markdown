---
layout: post
title: "Daily Journal"
date: 2014-04-28 14:11
comments: true
categories: 
flashcards:
  - front: What is `ignoredModules` useful for in the `broccoli-es6-concatenator` plugin?
    back: It prevents a file from being transpiled, and basically marks a module as something that'll be implemented later
---

## `npm install` git repos

NOTE: this section is not complete; placeholding for later.

After many abortive attempts to find the right syntax for running 
`npm install`, I figured I'd delve into what URL syntax it actually
expected, and why.

Here's a bunch of stuff that didn't work:

    npm install git+ssh@github.com:stefanpenner/ember-cli.git
    npm install https://github.com/stefanpenner/ember-cli.git

Why couldn't `npm install` just figure out what I meant? Well, I don't
know, but here's a breakdown of the above.

_This is a helpful resoure: https://help.github.com/articles/which-remote-url-should-i-use_

Basically, you can clone GitHub repos either with HTTPS or SSH urls. SSH
urls require an SSH keypair to generated on your computer and registered
to your GitHub accounts. 

So here's the first thing I tried:

    https://help.github.com/articles/using-ssh-agent-forwarding

This is an HTTPS url. 

Q: Why does/did GitHub even require a password for cloning a repo?
What's insecure about that read info? Possible answer: even if you don't
have read access to a repo, a man in the middle might tell you you do,
and then you're sending priv data, blah blah blah.

## `Gdiff`, diffing in vim

This was a very helpful resource: 

http://vimcasts.org/episodes/fugitive-vim-resolving-merge-conflicts-with-vimdiff/

    :Gdiff
    :ls # list all the open buffers in their names
    :diffget BUFSPEC # when inside a conflict region,
                     # say which buffer to get content from
    :diffput BUFSPEC # when inside a conflict region,
                     # say which buffer to get content from
    :only # close all buffer except this one

I ended up adding the following to my `.vimrc.after`:

    :nnoremap <Leader>dg :diffget <CR>
    :nnoremap <Leader>dp :diffput <CR>

Note that this arg-less form is useful when diffing between local
changes and your last checkin; I use it a bunch for `ember-cli` when I
call `ember init` to reset my app structure to the latest `ember-cli`
blueprint (note that this process is still pretty miserable).

## Broccoli `ignoredModules` and `legacyFilesToAppend`

These options come from the `broccoli-es6-concatenator`.

- `ignoredModules`: don't transpile this module or add it to the list of
  importable modules. This is useful when you have a file that's already
  in AMD format (not ES6), and you want to be able to es6 `import` that
  module, so you put it in `ignoredModules` so it's not treated as an
  es6 file that needs to be imported.
- `legacyFilesToAppend`: non-es6 files (global libraries) that should be
  appended to the end of the final output JS file. 

Note: `loaderFile` is automatically added as a legacy files, why, duh,
because the loader file obviously needs to be a global, non-module file.

So, wtf does this mean (the latest iteration of the blueprint
Brocfile.js from ember-cli):

    if (app.env !== 'production') {
      push.apply(app.ignoredModules, [
        'qunit',
        'ember-qunit'
      ]);

      push.apply(app.legacyFilesToAppend, [
        'test-shims.js',
        'ember-qunit/dist/named-amd/main.js'
      ]);
    }

Well, thanks to the geniuses in freenode IRC `#ember-cli`, I've learned
that:

- This shouldn't be in the blueprint Brocfile.js, but rather should be
  in the ember-cli lib `EmberApp` abstraction over the Brocfile.js, but
  anyway:
- The intent is that by specifying an `ignoredModules` item, you're
  basically saying "I intent to import a module with this name, and
  because I'm opting out of generating it now via an ES6 file, I'll be
  adding an AMD module for this file later"

And if you try to `import something from 'nonexistent-module'`, you'll
get a loader error.

This all seems really obvious, right? Naw, it's really freaking hard for
me to keep in my dumb brain. :(



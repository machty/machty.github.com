---
layout: post
title: "Quickly Peruse Gem Source: Vim + Tmux + bundle open"
date: 2013-01-13 15:45
comments: true
categories: 
- vim
- tmux
- bundle
- gems
---

Ever find yourself
working on a project and needing to dig into the source code of a Gem
you're using? In the past I used to just go to the github for that gem
and use their project explorer, searching for particular commands using
their ultra helpful `t` command, but I got sick of having to do that, so
I found a better way using Vim + tmux + `bundle open`. The result is a
command I can run in Vim, which autocompletes gem names by looking
through `Gemfile.lock`, which splits the current tmux pane and runs a
new instance of Vim in the root directory of the Gem I'm looking for.

Even if you don't
share my exact configuration, you might learn something about any of the
following: Tmux, Vim, `bundle open`, and some Unix commands, and the end
result code is pretty easily modifiable.

<!-- more -->

## My setup

I do all my work on the [iTerm2](http://www.iterm2.com "iTerm2")
terminal, using [tmux](http://tmux.sourceforge.net/) as better
screen-splitting replacement for `screen`, and Vim as my editor
(with the [Janus](https://github.com/carlhuda/janus) plugin bundle).

{% img /images/tmuxsetup.jpg %}

I figured the easiest way for me to address the above need for quick Gem
source code perusal would be to split my Vim pane and open a new
instance of Vim in the root directory of the Gem source code. 
`bundle open` to the rescue.

## `bundle open`

`bundle open <GEMNAME>` will open whatever editor you've provided in the
`$EDITOR` environment variable to the root of the provided gem name.
Thanks to [Gordon](https://github.com/ghempton) for keying me into this;
it's extremely useful.

## Custom Vim command

Here's what I ended up throwing into my .vimrc (actually .vimrc.after
since I'm using Janus).

{% codeblock lang:vim %}
" Split current tmux window, running `bundle open` on the 
" argument-specified Gem name. Auto-completes from Gemfile.lock.
command! -nargs=* -complete=custom,ListGems BundleOpen silent execute "!tmux splitw 'bundle open <args>'"

" The function used to produce the autocomplete results.
fun ListGems(A,L,P)
  " Note that vim will filter for us... no need to do anything with A args.
  return system("grep -s '^ ' Gemfile.lock | sed 's/^ *//' | cut -d ' '  -f1 | sed 's/!//' | sort | uniq")
endfun

" Shortcut mapping.
nmap <leader>o :BundleOpen 
{% endcodeblock %}

Basically, `command!` declares the command that tells Tmux to split the
current pane and call `bundle open` with whatever I pass to the Vim
function. The `-complete=custom,ListGems` portion tells it that it
should use the output of the custom function `ListGems` as its
auto-complete dictionary, which is a _completely awesome_ feature.

The auto-complete dictionary I used is all the gems found in the
Gemfile.lock file if it exists. From left to right I (`grep`) filter out
lines that don't begin with gem names, (`sed`) get rid of preceding
whitespace, (`cut`) filter out everything after the first space, (`sed`)
get rid of exclamation points (apparently they're used for `git` repo
gems in Gemfile.lock), `sort` the list, and `uniq` to remove duplicates
(`sort` and `uniq` are probably optional but they're harmless and I didn't
want to fidget). 

Finally, I create a mapping so that when I'm in normal mode, I can just
type `\o` and Vim will start filling out the command `BundleOpen` so
that all I have to type is the gem name, which I can autocomplete.


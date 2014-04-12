---
layout: post
title: "Emblem.js - Indented templating targeting Handlebars.js and Ember.js"
date: 2013-01-27 14:13
comments: true
categories: 
- emblem
- ember
- templates
- indentation
- handlebars
- pegjs
- parsing
---

I wrote a templating language called
[Emblem](https://github.com/machty/emblem.js) which you can use instead
of Handlebars to write templates for your views in Ember.js (and soon,
in any other setting). It's still very new, and I definitely have more
planned as far as syntax enhancements/refinements, but what's there is
pretty solid and I hope you'll take it for a test drive and give me some
feedback, or better yet submit a PR or two. 

You can check out a zany little demo [here](http://jsbin.com/ulegec/17/edit), which
gives you an opportunity to try out some syntactical experiments
yourself. 

Aaand 
[here](https://speakerdeck.com/machty/emblem-dot-js-ember-targeting-indentation-based-templates)
are the slides from the presentation at made at the NYC Ember.js meetup
I made this week. The rest of this post goes into some of the
motivation and architecture behind Emblem.

<!-- more -->

## Motivation

Here's what Handlebars (in an Ember setting) looks like:

{% codeblock lang:html %}
{% raw %}
<div id="main-container" class="padded active">
  <h1>Greetings, {{name}}</h1>

  {{! comment that doesn't get rendered. }}

  {{#if loggedIn}}
    <button {{action logout}}>Log Out</button>
  {{else}}
    <button {{action login}}>Log In</button>
  {{/if}}

  <div class="text-container">
    {{#each paragraphs}}
      <p>{{{this}}}</p>
    {{/each}}
  </div>
</div>
{% endraw %}
{% endcodeblock %}

and here's the equivalent Emblem.js code:

{% codeblock %}
{% raw %}
#main-container.padded.active
  h1 Greetings, {{name}}

  / comment that doesn't get rendered

  if loggedIn
    button click="logout" Log Out
  else
    button click="login" Log In

  .text-container
    each paragraphs
      p == this

  / Could also write the 
    .text-container = each paragraphs
      p == this
{% endraw %}
{% endcodeblock %}

Note how indentation is used to determine what gets placed inside HTML
elements or block Handlebars helpers. This prevents a lot of unnecessary
typing and keeps your code very neat (note that this certainly isn't a
new idea, see HAML/Slim/Jade/Python/etc).

More importantly, while Ember.js lets you use any templating language
you'd like, if you use something other than Handlebars, you miss out an
all of Ember's lovely data-binding functionality, which allows templates
to re-render themselves when the data they're tied to changes. 

![one does not simply use data-binding non-handlebars templates](/images/onedoesnot.png)

One of the hacks I used to allow me to write indentation-based templates
that played nicely with Ember was to use Hamlbars, a light-weight
wrapped around HAML that exposed an `hb` helper to the HAML code which
could be used to generate the {{}} mustache'd Handlebars code, that
Handlebars would then process as if you'd just written the mustache'd
HTML yourself. A Hamlbars version of the above example would go as
follows:

{% codeblock lang:haml %}
{% raw %}
#main-container.padded.active
  %h1 Greetings, {{name}}

  -# comment that doesn't get rendered

  = hb 'if loggedIn' do
    %button{ _action: "logout" } Log Out
    = hb 'else'
    %button{ _action: "login" } Log In

  .text-container
    = hb 'each paragraphs' do
      %p 
        = hbb 'this'

{% endraw %}
{% endcodeblock %}

I prefer this over Handlebars, but it's still extremely jank, due to the
`hb` helper showing up all over the place and the fact that you can't
properly indent the `else` the way you'd expect without closing the
{{#if}} tag before injecting the `else`. 

So, with all this in mind, I wrote Emblem.js for the following reasons:

1. I hate writing HTML, particularly typing angle brackets and
   backslashes and closing tags.
1. Hamlbars is still mad jank.
1. Beyond fixing issues inherent in Handle/Hamlbars, I had a lot of
   ideas for a clean, flexible, Ember-targeting syntax.
1. I wanted to learn how to write a parser.

## Solution: Emblem.js

Emblem.js saves the day as follows:

1. It's indentation-based
1. It internally compiles to Handlebars, and therefore has access to all
   of Handlebars' features/helpers, including the ability to bind to
   data in an Ember context
1. It spares you all sorts of ugly markup prefix characters by assuming
   that either an html element or handlebars property/helper lookup
   starts a line. They're equally first-class citizens, the second-class
   citizen being line-starting text, which can be easily specified using
   the `|` prefix. 
1. It's all in JS, so you can compile in the browser.

### HTML elements and HB Helpers as equal first-class citizens

Check out the following valid Emblem:

{% codeblock %}
{% raw %}
  p Hello
  foo Hello
{% endraw %}
{% endcodeblock %}

Emblem doesn't intermediately compile to Handlebars input text, but if
it did, the above code would generate something like:

{% codeblock lang:html %}
{% raw %}
  <p>Hello</p>
  {{foo Hello}}
{% endraw %}
{% endcodeblock %}

So, a paragraph tag and helper invocation. How does Emblem know the
difference? Answer: Emblem looks out for the known HTML helpers and
assumes everything else that starts a line is a Handlebars mustache
invocation. This is bound to raise an eyebrow and furrow the other for
some people, but 1) Why would you name your helpers the same things as
HTML tags, and 2) If you really need custom elements (future versions
of) Emblem allow you to escape these elements either by specifying a
whitelist in your build tools or simply by preceding your non-standard
HTML with a `%`, similar to what HAML makes you do all the time. But
such corner cases should be very rare in the typical front-end dev
workflow. 

## How's it built?

Emblem takes your code and does the following:

1. Runs the code through a preprocessor to strip empty lines and
   validate indentation, replacing indentation starts with an `INDENT`
   token and indentation ends with a `DEDENT` token.
1. Passes the pre-processed and lightly tokenized code through a PEG.js
   parser, which returns an Abstract Syntax Tree (AST) of Handlebars
   nodes.
1. Passes the HB AST to the Handlebars compiler, which generates the
   template function that Ember (and other frameworks) can use. 

### PEG.js

[PEG.js](http://pegjs.majda.cz/) is a JavaScript implementation of 
a [PEG compiler](http://en.wikipedia.org/wiki/Parsing_expression_grammar).
With PEG.js, you define a parser's grammar in a `.pegjs` file, then use
PEG.js to generate a compiler based on the provided grammar. You can
return anything you want from a PEG-based compiler, but it's most common
to return some form of tree structure, since those are easy for
compilers to work with. In Emblem's case, the object returned from the
PEG parser is a Handlebars AST (the same that would have been generated
if you'd used Handlebars' Jison compiler to parse Handlebars code).

One thing to note about PEG is that it is a context-free parser, which
basically means that (without cheating) your PEG grammar can't rely on
changes in state to do its parsing. An example of "state"
would be, say, the current level of indentation of an Emblem template;
you can't write grammar code that says, "ok, now that I'm at level 2
indentation, I can handle 1 or 2 de-indentations, but I must throw an error
if I encounter 3 de-indentations." Rather, pure PEG requires that you
must always specify sequences of tokens that you universally expect to
encounter, regardless of the current state of the parser. The solution
to this is to first run your code through a preprocessor, which isn't
context-free, which will convert anything state-dependent to tokens that
PEG can reason about in a context-free setting. In Emblem's case, this
meant taking code like

```
  p
    span What's up
```

and pre-processing it into

```
  p<TERM><INDENT>span What's up<TERM><DEDENT>
```

Now that it's in the tokenized form, you could write PEG grammar like
the following, which will match the above `p` as an
`htmlTagAndOptionalAttributes` and detect (due to the indentation) that
the `span What's up` is the nested content in the (optional) block. 

```
htmlElementMaybeBlock = h:htmlTagAndOptionalAttributes _ TERM c:(INDENT content DEDENT)? 
```

This technique is how Emblem decides whether a certain line of Emblem
code is in block form or not, whether it's a Handlebars helper or an HTML element.

## Conclusion

Writing Emblem.js was extremely challenging yet extremely rewarding. If
you've never written anything like a parser before, definitely give it a
go. 

Emblem's getting there, but it's still not as polished as I would like.
I'd definitely appreciate whatever help I can get, so if you're feeling
saucy, check out the [Github Repo](https://github.com/machty/emblem.js), and submit
a PR. I'll continue to post updates to the syntax over the coming weeks.
Let me know how you think it's shaping up.


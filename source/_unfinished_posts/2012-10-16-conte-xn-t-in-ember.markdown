---
layout: post
title: "All Things Templates and the Brothers Conte[xn]t"
date: 2012-10-16 01:14
comments: true
categories: 
- ember.js
- context
- content
- templates
---
I never have any idea whether I stumble over the same concepts as others
when I'm trying to grok a new languge/framework/abstraction, but one of
my most persistent troubles I had with Ember.js was with the seemingly
blurry definitions of the words `context` and `content`, both of which
are pretty unavoidable in the course of Ember application development.
This blog is meant to serve as the final nail in the coffin of my (and
hopefully your) understanding of `context` and `content` in Ember.js.

Note that this blog is intentionally example-heavy so that it can
hopefully serve as a reference for how data can be tied to your
templates.

<!--more-->

## Templates and Contexts

Just to cover the basics, a `template` is chunk of fill-in-the-blanks
HTML, e.g.

{% assign name = '{{name}}' %}

{% codeblock lang:html %}
   <p>Good morning, {{name}}!</p>
{% endcodeblock %}

This same template can be re-used to say "Good morning, Steve!", "Good
morning, Alex!", "Good morning, Mussolini!", etc.  In order to turn a
template into real HTML, you need to provide the template a
`context` object that it'll use to fill in the blanks (i.e. everything
inside the curly braces). Example context objects corresponding to the
examples above would be `{ name: "Steve" }`, `{ name: "Alex" }`,
`{ name: "Mussolini" }`. 

A concise definition of `context` in this case would be:

> **context**: the object whose properties are used to fill in the
> blanks in a template.

Every `Ember.View` that uses a template to display its HTML must pass
that template a `context` object that they template will use to fill in
the blanks.

### Explicitly Specifying the Context

Let's start off with a ridiculously simple example
that you'll never use in a real app (click the + in the upper right of
the jsFiddle below to open a full-page 4-panel jsFiddle).

<iframe style="width: 100%; height: 200px"
src="http://jsfiddle.net/machty/mteRN/embedded/js,html,result"
allowfullscreen="allowfullscreen" frameborder="0"></iframe>

In this example, we set the `context` property of `HelloView` to a
JavaScript object, which means `HelloView`'s template will fill in the
`foo` blank with the value of the `foo` property on that JavaScript
object. Note that this example is ridiculous because you'll never
hardwire an object to the context property in such a direct manner; 
if you already know the object you'll be using as a
`context`, and all of its properties, why not just manually fill in
those blanks yourself directly in the template? 

But this example demonstrates the first rule to understand about Views,
templates, and contexts.

> **Rule #1**: The first place a View will look in deciding which
> context to pass to a template is its `context` property. If this
> property has been set, then the template will use this object's
> properties to fill in its blanks.

As you can probably guess, the tricky part is figuring out what the
default behavior is when you don't explicitly specify a context object,
but we'll get there when we get there.

#### Ember.Object as a Context

Note that you can also use (and almost always do use) `Ember.Object`s as
context objects, as demonstrated here:

<iframe style="width: 100%; height: 200px"
src="http://jsfiddle.net/machty/ZqCwZ/embedded/js,html,result"
allowfullscreen="allowfullscreen" frameborder="0"></iframe>

#### contextBinding

Just like with any other property in Ember, rather than hard-wiring
the `context` property, you can using a binding in its place. That way,
whatever object the context property is bound to will be used to fill in
the blanks on the template property. To do this, simply specify the
`contextBinding` property instead of the `context` property:

<iframe style="width: 100%; height: 250px"
src="http://jsfiddle.net/machty/UbcbH/embedded/js,html,result"
allowfullscreen="allowfullscreen" frameborder="0"></iframe>

So, HelloView will pass `App.someProperty` to its template. The template
fills in the `foo` blank with `App.someProperty.foo`.

Here's a similar example just for kicks which uses the App itself as the
context object:

<iframe style="width: 100%; height: 250px"
src="http://jsfiddle.net/machty/Ta34x/embedded/js,html,result"
allowfullscreen="allowfullscreen" frameborder="0"></iframe>

### Omitting the Context Property

So what happens when you don't explicitly specify the `context` on a
View class? 

Given that Ember is a framework that is, like many others, based on
the Model-View-Controller design pattern, this next rule shouldn't come
as a huge surprise:

> **Rule #2**: Assuming the `context` property wasn't specified, a View
> will try to use its `controller` property as the template's context.

Let's look at an example:


TODO: http://jsfiddle.net/machty/sLFBj/





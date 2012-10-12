---
layout: post
title: "DRY and Tie Your Ember Routes"
date: 2012-09-28 13:54
comments: true
categories: ember.js routing dry
---
#### UPDATE 10/1/12: see bottom the post for avoiding infinite loop issues

A common complaint about Ember.js routing is that seems to force you to
create pairs of extremely light-weight, useless Views and Controllers
for each new route you create. Another is that it's not particular
obvious how data ought to be shared between routes/controllers. Here's
one way to cut down on the seeming boilerplate while linking your data.

<!--more-->
  
Consider the following example router
that describes an application that allows you to create new Campaigns,
but the forms for filling out all the information about a Campaign are
split between multiple pages. 

{% codeblock app_router.js.coffee lang:coffeescript %}
App.Router = Em.Router.extend
  root: Em.Route.extend
    # ... index route, redirect-to's, etc.

    new_campaign: Em.Route.extend
      route: '/new_campaign'
      connectOutlets: (router) ->
        # 1. Instantiate a NewCampaignController and NewCampaignView,
        # and inject the latter into applicationController's outlet.
        # also create the empty Campaign object that will be 
        # shared between the multiple pages of forms and pass it in
        # as the context object to the controller.
        router.get('applicationController').connectOutlet('newCampaign', App.Campaign.createRecord())

      basic_info: Em.Route.extend
        route: '/basic_info'
        connectOutlets: (router) ->
          # 2. Create BasicInfoController and BasicInfoView, inject
          # into the NewCampaignView outlet.
          router.get('newCampaignController').connectOutlet('basicInfo')

      more_info: Em.Route.extend
        route: '/more_info'
        connectOutlets: (router) ->
          router.get('newCampaignController').connectOutlet('moreInfo')

      #... a third page
{% endcodeblock %}

There's two main problems with the code above:

1. The `basic_info` and `more_info` child state controllers haven't yet
   been connected to the Campaign object created for the parent
   `new_campaign` state.
1. Already, you've got to implement a bunch of nearly empty Views and
   Controllers, namely:

{% codeblock app_router.js.coffee lang:coffeescript %}
App.NewCampaignView = Em.View.extend
  templateName: "new_campaign"
App.NewCampaignController = Em.Controller.extend()

App.BasicInfoView = Em.View.extend
  templateName: "basic_info"
App.BasicInfoController = Em.Controller.extend()

App.MoreInfoView = Em.View.extend
  templateName: "more_info"
App.MoreInfoController = Em.Controller.extend()
{% endcodeblock %}

First off, if you're a 1-to-1 class-to-file kind of person, your
codebase, app namespace, and editor tab space will bloat with nearly
empty View and Controller definitions. Sucks.

Fortunately, if the `connectOutlet` function comes in all sorts of
flavors, one where you you can pass in an options hash rather than
a string to specify exactly which Views / Controllers to create and what
your context option should be. Let us kill off the `BasicInfo`- and `MoreInfo`-
Controllers via the following:

{% codeblock lang:coffeescript %}
# App.Router = ...

      basic_info: Em.Route.extend
        connectOutlets: (router) ->
          router.get('newCampaignController').connectOutlet
            viewClass: App.BasicInfoView

      more_info: Em.Route.extend
        connectOutlets: (router) ->
          router.get('newCampaignController').connectOutlet
            viewClass: App.MoreInfoView
{% endcodeblock %}

Turns out we've actually solved both problems: we no longer need
`BasicInfoController` or `MoreInfoController`, and we've actually 
tied the templates for `BasicInfoView` and `MoreInfoView` correctly
to the Campaign object in NewCampaignController, and how exactly does
that work?

### Default Context Resolution: parentView

Well, ever since 
[Ember changed the way it resolves contexts](https://gist.github.com/2494968), 
the context of a template is determined, by default, by looking up the
`controller` property of the View and using that if it exists, otherwise
it checks up the chain of `parentView`s to see if any of them have
defined a `controller` property to use as the context. `BasicInfoView`
and `MoreInfoView` don't have controllers set (since we're using the
`viewClass`-only form of `connectOutlet`), so their contexts resolve to
their `parentView`'s `controller`, namely `NewCampaignController`.
Therefore, the Handlebars templates for `BasicInfoView` and
`MoreInfoView` now use the `Campaign` object as their context. 

### Can we do better?

You might be itching to get rid of `BasicInfo-` and `MoreInfoView` as
well, since all they do is specify their `templateName`. You could do
this, if you wanted, by doing 
`viewClass: Em.View.extend(templateName: "basic_info")`, but that seems
like overkill to me. Plus, you'd lose the benefits of being able to,
say, automatically focus a text field via the View's `didInsertElement`
hook. 

### Where can I learn more?

Documentation on Ember routing is still pretty meager, so I'd definitely
encourage you to really dig into the Ember source, particularly the test
cases that deal with these kinds of issues. For example, tucked right in
the middle of `controller_test.js` is

{% codeblock app_router.js.coffee lang:javascript %}
test("if the controller is explicitly set to null while connecting an outlet, the instantiated view will inherit its controller from its parent view", function() { ...
{% endcodeblock %}

Which isn't exactly what's happening regarding context resolution, but still clued me into this
approach.

### Update: Infinite Loop Gotcha

I've been refactoring like a madman since discovering this and in some
cases I was getting stack overflows that were hard to trace down, but I
found the cause: if the `viewClass` you specify has an unnamed
`outlet` in its template, you'll get an infinite loop. I'm 90% sure
the reason why is that when you use the `viewClass`-only form of
connectOutlet, the default outlet name resolves to `view` (the default)
and steps on the namespace toes of the parent view outlet that 1) had
the same name (view) and was 2) (more importantly) tied to the same
single controller. So, there's namespace collisions. You can avoid this
by either getting rid of the leaf view's `outlet` (which might be
the case if you've been unquestioningly throwing outlets into templates
that don't actually inject child views... we're probably all guilty of
this at some point in our struggles with the router), or, if you
actually need the outlet, just give it a sensible name that won't
collide with any other outlet attached to the shared controller. Then
when you want to inject a view into _that_ outlet, you can do:

{% codeblock app_router.js.coffee lang:coffeescript %}

  basic_info: Em.Route.extend
    route: '/basic_info'
    connectOutlets: (router) ->
      router.get('newCampaignController').connectOutlet
        viewClass: App.BasicInfoView

    index: Em.Route.extend
      route: '/'

    captcha: Em.Route.extend
      route: '/captcha'
      connectOutlets: (router) ->
        # Assume theres an outlet named captcha in the basic_info template.
        router.get('newCampaignController').connectOutlet
          viewClass: App.CaptchaView
          outletName: 'captcha'

{% endcodeblock %}


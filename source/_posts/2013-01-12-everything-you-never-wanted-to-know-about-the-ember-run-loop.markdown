---
layout: post
title: "Everything You Never Wanted to Know About the Ember Run Loop"
date: 2013-01-12 13:09
comments: true
categories: 
- ember.js
- run loop
- binding:w
---

Just posted a
[Giant Ass Response on Stack Overflow](http://stackoverflow.com/questions/13597869/what-is-ember-runloop-and-how-does-it-work/14296339#14296339) about the Ember Run Loop. I've reproduced the text below. The question basically was: What is the Run Loop? How long does it take? When does it fire up? Can I expect views to be rendered to the DOM by the end of the run loop? etc. etc. Take a look, I think there's some good stuff in there. Without further ado:

First off, read these:

[Sproutcore Run Loop, part 1](http://blog.sproutcore.com/the-run-loop-part-1/)
[Sproutcore Run Loop, part 2](http://blog.sproutcore.com/the-run-loop-part-2/)

They're not 100% accurate to Ember, but the core concepts and motivation behind the RunLoop still generally apply to Ember; only some implementation details differ. But, on to your questions:

<!-- more -->

### When does Ember RunLoop start. Is it dependant on Router or Views or Controllers or something else?

All of the basic user events (e.g. keyboard events, mouse events, etc) will fire up the run loop. This guarantees that whatever changes made to bound properties by the captured (mouse/keyboard/timer/etc) event are fully propagated throughout Ember's data-binding system before returning control back to the system. So, moving your mouse, pressing a key, clicking a button, etc., all launch the run loop.

### how long does it approximately take (I know this is rather silly to asks and dependant on many things but I am looking for a general idea, or maybe if there is a minimum or maximum time a runloop may take)

At no point will the RunLoop ever keep track of how much time it's taking to propagate all the changes through the system and then halt the RunLoop after reaching a maximum time limit; rather, the RunLoop will always run to completion, and won't stop until all the expired timers have been called, bindings propagated, and perhaps _their_ bindings propagated, and so on. Obviously, the more changes that need to be propagated from a single event, the longer the RunLoop will take to finish. Here's a (pretty unfair) example of how the RunLoop can get bogged down with propagating changes compared to another framework (Backbone) that doesn't have a run loop: http://jsfiddle.net/jashkenas/CGSd5/ . Moral of the story: the RunLoop's really fast for most things you'd ever want to do in Ember, and it's where much of Ember's power lies, but if you find yourself wanting to animate 30 circles with Javascript at 60 frames per second, there might be better ways to go about it than relying on Ember's RunLoop. 

### Is RunLoop being executed at all times, or is it just indicating a period of time from beginning to end of execution and may not run for some time.

It is not executed at all times -- it has to return control back to the system at some point or else your app would hang -- it's different from, say, a run loop on a server that has a `while(true)` and goes on for infinity until the server gets a signal to shut down... the Ember RunLoop has no such `while(true)` but is only spun up in response to user/timer events. 

### If a view is created from within one RunLoop, is it guaranteed that all its content will make it into the DOM by the time the loop ends?

Let's see if we can figure that out. One of the big changes from SC to Ember RunLoop is that, instead of looping back and forth between `invokeOnce` and `invokeLast` (which you see in the diagram in the first link about SproutCore's RL), Ember provides you a list of 'queues' that, in the course of a run loop, you can schedule actions (functions to be called during the run loop) to by specifying which queue the action belongs in (example from the source: `Ember.run.scheduleOnce('render', bindView, 'rerender');`). 

If you look at `run_loop.js` in the source code, you see `Ember.run.queues = ['sync', 'actions', 'destroy', 'timers'];`, yet if you open your JavaScript debugger in the browser in an Ember app and evaluate `Ember.run.queues`, you get a fuller list of queues: `["sync", "actions", "render", "afterRender", "destroy", "timers"]`. Ember keeps their codebase pretty modular, and they make it possible for your code, as well as its own code in a separate part of the library, to insert more queues. In this case, the Ember Views library inserts `render` and `afterRender` queues, specifically after the `actions` queue. I'll get to why that might be in a second. First, the RunLoop algorithm:

The RunLoop algorithm is pretty much the same as described in the SC run loop articles above: 

- You run your code between RunLoop `.begin()` and `.end()`, only in Ember you'll want to instead run your code within `Ember.run`, which will internally call `begin` and `end` for you. (Only internal run loop code in the Ember code base still uses `begin` and `end`, so you should just stick with `Ember.run`)
- After `end()` is called, the RunLoop then kicks into gear to propagate every single change made by the chunk of code passed to the `Ember.run` function. This includes propagating the values of bound properties, rendering view changes to the DOM, etc etc. The order in which these actions (binding, rendering DOM elements, etc) are performed is determined by the `Ember.run.queues` array described above:
- The run loop will start off on the first queue, which is `sync`. It'll run all of the actions that were scheduled into the `sync` queue by the `Ember.run` code. These actions may themselves also schedule more actions to be performed during this same RunLoop, and it's up to the RunLoop to make sure it performs every action until all the queues are flushed. The way it does this is, at the end of every queue, the RunLoop will look through all the previously flushed queues and see if any new actions have been scheduled. If so, it has to start at the beginning of the earliest queue with unperformed scheduled actions and flush out the queue, continuing to trace its steps and start over when necessary until all of the queues are completely empty. 

That's the essence of the algorithm. That's how bound data gets propagated through the app. You can expect that once a RunLoop runs to completion, all of the bound data will be fully propagated. So, what about DOM elements? 

The order of the queues, including the ones added in by the Ember Views library, is important here. Notice that `render` and `afterRender` come after `sync`, and `action`. The `sync` queue contains all the actions for propagating bound data. (`action`, after that, is only sparsely used in the Ember source). Based on the above algorithm, it is guaranteed that by the time the RunLoop gets to the `render` queue, all of the data-bindings will have finished synchronizing. This is by design: you wouldn't want to perform the expensive task of rendering DOM elements _before_ sync'ing the data-bindings, since that would likely require re-rendering DOM elements with updated data -- obviously a very inefficient and error-prone way of emptying all of the RunLoop queues. So Ember intelligently blasts through all the data-binding work it can before rendering the DOM elements in the `render` queue. 

So, finally, to answer your question, yes, you can expect that any necessary DOM renderings will have taken place by the time `Ember.run` finishes. Here's a jsFiddle to demonstrate: http://jsfiddle.net/machty/6p6XJ/328/

## Other things to know about the RunLoop

### Observers vs. Bindings

It's important to note that Observers and Bindings, while having the similar functionality of responding to changes in a "watched" property, behave totally differently in the context of a RunLoop. Binding propagation, as we've seen, gets scheduled into the `sync` queue to eventually be executed by the RunLoop. Observers, on the other hand, fire _immediately_ when the watched property changes without having to be first scheduled into a RunLoop queue. If an Observer and a binding all "watch" the same property, the observer will always be called 100% of the time earlier than the binding will be updated.

### `scheduleOnce` and `Ember.run.once`

One of the big efficiency boosts in Ember's auto-updating templates is based on the fact that, thanks to the RunLoop, multiple identical RunLoop actions can be coalesced ("debounced", if you will) into a single action. If you look into the `run_loop.js` internals, you'll see the functions that facilitate this behavior are the related functions `scheduleOnce` and `Em.run.once`. The difference between them isn't so important as knowing they exist, and how they can discard duplicate actions in queue to prevent a lot of bloated, wasteful calculation during the run loop.

### What about timers?

Even though 'timers' is one of the default queues listed above, Ember only makes reference to the queue in their RunLoop test cases. It seems that such a queue would have been used in the SproutCore days based on some of the descriptions from the above articles about timers being the last thing to fire. In Ember, the `timers` queue isn't used. Instead, the RunLoop can be spun up by an internally managed `setTimeout` event (see the `invokeLaterTimers` function), which is intelligent enough to loop through all the existing timers, fire all the ones that have expired, determine the earliest future timer, and set an internal `setTimeout` for that event only, which will spin up the RunLoop again when it fires. This approach is more efficient than having each timer call setTimeout and wake itself up, since in this case, only one setTimeout call needs to be made, and the RunLoop is smart enough to fire all the different timers that might be going off at the same time.

### Further debouncing with the `sync` queue

Here's a snippet from the run loop, in the middle of a loop through all the queues in the run loop. Note the special case for the `sync` queue: because `sync` is a particularly volatile queue, in which data is being propagated in every direction, `Ember.beginPropertyChanges()` is called to prevent any observers from being fired, followed by a call to `Ember.endPropertyChanges`. This is wise: if in the course of flushing the `sync` queue, it's entirely possible that a property on an object will change multiple times before resting on its final value, and you wouldn't want to waste resources by immediately firing observers per every single change. 

{% codeblock lang:javascript %}
        if (queueName === 'sync') {
           log = Ember.LOG_BINDINGS;
           if (log) { Ember.Logger.log('Begin: Flush Sync Queue'); }
           Ember.beginPropertyChanges();
           Ember.tryFinally(tryable, Ember.endPropertyChanges);
           if (log) { Ember.Logger.log('End: Flush Sync Queue'); }
        } else {
           forEach.call(queue, iter);
        }
{% endcodeblock %}

Hope this helps. I definitely had to learn quite a bit just to write this thing, which was kind of the point.

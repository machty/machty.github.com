---
layout: post
title: "batteryPOP is Live"
date: 2012-10-12 10:50
comments: true
categories: batterypop ember.js
---

You can check out the latest [Useful Robot](http://www.usefulrobot.io)
project at [batteryPOP.com](http://www.batterypop.com).

batteryPOP is a children's website featuring a bubbly, animated,
tree-based menu that drives kids to the videos they want to watch and
articles they want to read. It was written in 
[Ember.js](http://www.emberjs.com)/Rails and had to look good on the
iPad, so we couldn't use any Flash, though the effect is largely the
same. 

<!-- more -->

## Repositionables

I'd [presented](https://speakerdeck.com/u/machty/p/ember-meetup) on some
of the challenges and lessons learned from building batteryPOP as a
lightning talk at the last 
[NYC Ember Meetup](http://www.meetup.com/EmberJS-NYC/), specifically
focusing on how to use a `Repositionable` mixin in conjunction with
position formulas so that views can automatically get notified when
browser dimensions change and automatically animate themselves to the
correct new position and scale. This is what facilitates the nifty
auto-adjust feature on batteryPOP.com when you scale the browser window.
Try it. It's nifty. 

It's also what allows the site to 'just work' when
viewed on a variety of different devices; there's no special iPad
version of the site, or device-specific CSS, just a bunch of Views that
know how to scale and position themselves based on browser dimensions
and a suite of reusable position formulas.

## PagedNodeOrchestrator

Also discussed was what I called the `PagedNodeOrchestrator`, which
handles the paging and animation of children nodes at a certain level in
the tree-based menu structure. If you go to batteryPOP.com and click
What's Poppin', you're 1 level deep in the tree menu, and there are (at
present) 12 nodes to display which get split into 2 pages of 6. Paging
left and right causes nodes to animate in and out of existence.

Furthermore, there are instances when user actions cause nodes to be
added/removed from the list (adding/removing items from your homepage),
and the menu will need to automagically rebalance and occasionally
collapse 2 pages into one and so on and so on. Due to all of the insane
whack-a-mole corner cases that presented themselves once I started in on
the more dynamic user homepage, the only solution was to write a
`PagedNodeOrchestrator`, which (similar to and based on
`Ember.CollectionView`) responds to changes in an underlying array of
models and automatically handles the generation, deletion, and animation
of their associated views as models are added/removed to the underlying
array and the `currentPageNumber` changes. Once I'd nailed down the code
to handle the basic paging/addition/deletion, all of those corner cases
resolved themselves. You can imagine my fist-pumping, Adderall-fueled
delight at Fourthmeal o'clock. 

### Code Excerpt

Here's all the important bits of the `PagedNodeOrchestrator` for anyone
who's interested in constructing a similar View-ish structure that
responds to changes in an underlying array. I've left some of the more
Shakespearian commenting intact.

{% codeblock paged_node_orchestrator.js.coffee lang:coffeescript %}
App.PagedNodeOrchestrator = Em.Object.extend

  init: ->
    @set "nodeViews", []
    @_nodeModelsDidChange()

  # When nodeModels changes, handle observer changes and
  # notify our callback. Note that a change in nodeModels
  # means that someone changed the entire fucking
  # array, and not just a few elements in there.
  # We take this opportunity to let our arrayWillChange
  # observer know what's up.
  _nodeModelsWillChange: Ember.beforeObserver((->
    if nodeModels = @get('nodeModels')
      nodeModels.removeArrayObserver @
    len = if nodeModels then nodeModels.get("length") else 0
    @arrayWillChange(nodeModels, 0, len)
  ), 'nodeModels')

  _nodeModelsDidChange: Ember.observer(( ->
    if nodeModels = @get('nodeModels')
      nodeModels.addArrayObserver @

    len = if nodeModels then nodeModels.get("length") else 0
    @arrayDidChange(nodeModels, 0, null, len)
  ), 'nodeModels')

  # Ember.sendEvent(this, '@array:before', [this, startIdx, removeAmt, addAmt]);
  arrayWillChange: (___, start, removedCount) ->

    # Basically, I need to cast away and destroy the nodeViews
    # associated with the deleted nodeModels in nodeModels. I'll
    # shorten the nodeViews array here and then add to it
    # in didChange
    @destroyNodeViewRange(start, removedCount)

    # Now remove those nodeViews from the list.
    @get("nodeViews").replace(start, removedCount, 0)

  arrayDidChange: (nodeModels, start, removed, added) ->

    # Fill in nodeViews with undefined space. 
    nodeViews = get(@, 'nodeViews')
    nodeViews.replace(start, 0, new Array(added))

    modelLen = if nodeModels then nodeModels.get("length") else 0
    viewLen  = if nodeViews then nodeViews.get("length") else 0
    Ember.assert(fmt("Node arrays out of sync! %@ vs. %@", [modelLen, viewLen]), modelLen == viewLen)
    @refreshDisplay()

  currentPaging: ( ->
    # First, determine the balanced page size.
    TARGET_PAGE_SIZE = 6
    nodeModels = @get "nodeModels"
    len = if nodeModels then nodeModels.length else 0
    numPages = Math.ceil(len / TARGET_PAGE_SIZE) || 1
    nodesPerPage = Math.ceil(len / numPages)

    # Now determine the range of visible node indexes
    # given the currentPageIndex. We also have to make sure
    # to stay within the bounds in case we lost a bunch of nodes
    # and we were on a later page.
    currentPageIndex = Math.min(@get("currentPageIndex"), numPages - 1)
    visibleStart = currentPageIndex * nodesPerPage
    visibleEnd = Math.min(len, visibleStart + nodesPerPage)
    currentPageSize = visibleEnd - visibleStart

    {
      numPages: numPages
      currentPageIndex: currentPageIndex
      maxNodesPerPage: nodesPerPage
      currentPageSize: currentPageSize

      # Indexes controlling which nodes are currently displayed:
      # [ visibleStart, visibleEnd )
      visibleStart: visibleStart
      visibleEnd: visibleEnd
    }
  ).property("currentPageIndex", "nodeModels.length")

  refreshDisplay: (force = false) ->

    nodeModels = @get "nodeModels"

    # Calculate paging and update properties.
    currentPaging = @get "currentPaging"
    @set "numPages", currentPaging.numPages
    @set "currentPageIndex", currentPaging.currentPageIndex
    visibleStart = currentPaging.visibleStart
    visibleEnd = currentPaging.visibleEnd
    currentPageSize = currentPaging.currentPageSize

    # Loop through all models, creating nodeViews in the visible spectrum
    # and hiding the ones that aren't supposed to be there.
    nodeViews = @get("nodeViews")

    for idx in [0...(nodeModels.length)]
      nodeModel = nodeModels[idx]
      nodeView = nodeViews[idx]

      if nodeView
        # NodeView has been created. Should it be here?
        if visibleStart <= idx < visibleEnd
          # Yes, it should. Make sure it's in the right place.
          @presentNodeView(nodeView, (idx - visibleStart) / currentPageSize + overlapOffset)
        else
          # No, it shouldn't be here. Send it in the proper direction
          # if it's actually visible
          continue if nodeView.getPath("displayProperties.opacity") < 0.1
          positionFormula = if idx < visibleStart
            App.PagedOutRightPosition
          else
            App.PagedOutLeftPosition
          nodeView.set "positionFormula", positionFormula
          nodeView.notifyPropertyChange "positionFormula"
      else
        # No nodeview exists in this slot yet. Should we create on?
        if visibleStart <= idx < visibleEnd
          console.log "Index #{idx}: Creating node here"
          # Yes we should.
          nodeView = App.nodeViewFactory(nodeModel)
          nodeViews[idx] = nodeView
          @presentNodeView(nodeView, (idx - visibleStart) / currentPageSize + overlapOffset, true)

  presentNodeView: (nodeView, orbitRatio, firstDisplay = false) ->
    nodeView.set "stackController", @
    nodeView.set "orbitRatio", orbitRatio
    nodeView.set "positionFormula", App.PrePresentPosition if firstDisplay

    # TODO: combine into one timer event?
    positioner = =>
      #debugger
      nodeView.set "positionFormula", App.OrbitingPosition
      nodeView.notifyPropertyChange "positionFormula"

    if firstDisplay
      runLater 1, positioner
    else
      positioner()

  # @param {callback}: function(nodeView, index)
  forEachVisibleNodeView: (callback) ->
    currentPaging = @get "currentPaging"
    nodeViews = @get "nodeViews"

    visibleStart = currentPaging.visibleStart

    for idx in [visibleStart...(currentPaging.visibleEnd)]
      nodeView = nodeViews[idx]
      newNodeView = callback nodeView, idx - visibleStart
{% endcodeblock %}

### Monitoring Changes on an Underlying Array

So, to create any sort of object that responds to changes in an
underlying array (in Ember.js), one must

1. Observe changes to the entire array property (i.e. handle the case
   when someone sets `content` to an entirely different array, rather
   than just adding to / removing from the existing array)
1. Use this observer to call `addArrayObserver`/`removeArrayObserver` on the
   new/old array so that we can receive notifications on when individual
   elements are added/removed from the array. 

This is the pattern that my `PagedNodeOrchestrator` follows, which
totally ripped off the pattern from the source for
`Ember.CollectionView`. Definitely take a look at the `CollectionView`
source for better commenting and less CoffeeScript and curse words. 

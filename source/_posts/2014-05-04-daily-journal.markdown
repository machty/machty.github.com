---
layout: post
title: "Daily Journal"
date: 2014-05-04 10:11
comments: true
categories: 
- DAS
flashcards:
  - front: SRP
    back: "Single Responbility Principle: a class should do only one thing"
  - front: TDA
    back: Tell Don't Ask - prefer telling an object to do something vs asking it its properties and deciding for yourself
flashcards:
  - front: "Vim: surround a word in ']'"
    back: "vsiw]"
  - front: "Vim: surround a chunk word in ']'"
    back: "vsiW]"
  - front: "Vim: change surrounding ' to \""
    back: "cs\"'"
  - front: "Vim: delete surrounding \""
    back: "ds\""
  - front: "Vim: wrap line in parens"
    back: "yss("
  - front: "Design principles: How can TDA and SRP conflict?"
    back: "Either you stuff all the things that the User class can handle in user domain-specific terms (which breaks Single Responsibility Principle), or you add additional classes that know enough about User to ask it for property and values and make transformations/decisions based on that knowledge (which breaks Tell Don't Ask)"
  - front: "Quick way to mark an rspec test as pending"
    back: "change `it` to `xit`"
  - front: "Cisgender"
    back: "aka cissexual; a person whose gender matches that assigned at birth"
  - front: "HAL"
    back: "Hypermedia Application Language; missing some features that make json api rad"
---

## Vim surround

https://github.com/tpope/vim-surround

- ysiw] : surround a word in ]
- ysiW] : surround a chunk word in ]
- cs"' : change surrounding " to '
- ds" : delete surrounding "
- yss( : wrap line in parens

## DAS: Conflicting Principles

- User/profile/account
  - All this other stuff that relates to that single giant model
- User
  - `disable!`
  - `send_disable_notication`
- Law of demeter
  - Motivation for decomposition
  - move controller logic to model `enforce_good_standing!`
- User model will get huge; lots of complexity there.
- Pull out service classes, e.g. GoodStandingPolicy, or
  AccountStandingPolicy
  - `#initialize(user)`
  - `enforce!`
    - still breaks law of demeter.
    - change `cards.all?(&:invalid?)` to `all_cards_invalid?`
    - but this breaks Tell Don't Ask
      - TDA means asking an object about properties and deciding what to
        do instead of telling it to do things and giving it enough info
        to do so.
    - TDA vs Single Responsibility Principle (SRP)?
      - If you follow TDA, you end up putting responsibility back into
        User class, but now User class has much responsibility
- Pick one: SRP often makes sense

## DAS: Wrapping Third Party APIs

- e.g. accepting Braintree payment from secure redirect back to your
  site with data in QPs
- BrainTree API objects are deeply nested, causes handling code to suffer
- Goal: move traversal of these objs to a different class.
- Spec
  - Had to stub deeply nested crap
- TDD
  - it "konws the newest credit card"
  - qp is a stub

## Pend-out an Rspec test

    it "does something" {}
 
can be made pending via `xit`

    xit "does something" {}

## Cisgender

http://en.wikipedia.org/wiki/Cisgender

> Cisgender and cissexual (often abbreviated to simply cis) describe
> related types of gender identity where an individual's experience of
> their own gender matches the sex they were assigned at birth.

## Hypermedia API

Hyper = above

Media = well, media, but not just hypertext because more things than
just text can be conveyed

Examples:

- http://jsonapi.org/
- HAL - Hypermedia Application Language

Why JSON API over HAL? http://jsonapi.org/faq/

- HAL embeds child docs recursively; JSON API flattens the entire graph
  at the top level.
- JSON API uses IDs for linkage (as opposed to HAL's what)?
- See [Dan Gebhart](https://github.com/dgeb)'s response here re linkage:
  https://github.com/json-api/json-api/pull/123/files#r12265234





---
layout: post
title: "Daily Journal 2"
date: 2014-05-01 22:46
comments: true
categories: 
flashcards:
  - front: "RSA"
    back: "Encryption key is public, decryption secret. Used for generating symmetric key in TLS"
  - front: "Query param for telling QUnit to grep module names"
    back: "filter=wat"
---

## Cryptoballs

    openssl speed rsa
    openssl speed aes

### RSA

Encryption key is public. Decryption key is secret.
Used for generating symmetric key in TLS.

AES is way faster (TODO: wat?).

## Active-model serializers

How do tell an attribute to use a serializer?

Trick question: you don't; rather, if it has a serializer, it's probably
an association, not an attribute, so you probably want something like 

    has_many :action_items, serializer: ActionItemSerializer
    has_one :originator, serializer: OriginatorSerializer

and in both cases you can probably remove `serializer` once you de-stub
`action_items` and `originator`.

## QUnit filter

In Mocha JS test suites if you click a suite header, it'll run tests
only from that module or children by way of a `grep=blahlbahbl` query
param. I'm using [qunit-bdd](https://github.com/square/qunit-bdd), which
is a layer over QUnit, which generates a bunch of concatenated module
names based on the nested `describe`s and `context`s, which doesn't let
you easily run all the nested child modules of a top-level describe if
you're used to using the Module dropdown on the upper right. 

If you want to run a family of describe modules, you can manually 
provide a `filter` query param, e.g.:

    http://localhost:4200/tests?filter=LiveQuery

This runs all modules w "LiveQuery" is part of their name.


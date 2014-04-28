---
layout: post
title: "Daily Journal"
date: 2014-04-21 09:41
comments: true
categories: 
flashcards:
  - front: This is the state machine compiler that backs the Mongrel HTTP parsing engine
    back: Ragel (http://www.complang.org/ragel/)
  - front: Joyent's parser written in C was taken from this server's codebase
    back: nginx
  - front: Who was the author of nginx?
    back: Igor Sysoev
  - front: This Ruby server combines the Mongrel HTTP parser, Event Machine, and Rack, and can be configured to enable threading.
    back: Thin (http://code.macournoyer.com/thin/)
  - front: The author of Mongrel
    back: Zed Shaw
  - front: Is Puma the only multi-threaded Rails 4 HTTP server?
    back: No, there's Net::HTTP::Server, Phusion Passenger 4, Rainbows!, Reel, Thin, Webrick, Zbatery (http://stackoverflow.com/questions/17902386/is-puma-the-only-multi-threaded-rails-4-http-server)
  - front: A fork-less HTTP Rack server based on Rainbows! -> Unicorn -> Mongrel and inherits parts of each, supporting thread/fiber/event/actor concurrency (just not threads)
    back: Zbatery (http://zbatery.bogomip.org/)
  - front: Based on Unicorn, this HTTP Rack server is designed for applications that expect long request/response times and/or slow clients 
    back: Rainbows! (http://rainbows.rubyforge.org/)
  - front: For Rack applications not heavily bound by slow external network dependencies, consider this instead as it simpler and easier to debug.
    back: Unicorn
  - front: If you're on a small system, or write extremely tight and reliable code and don't want multiple worker processes, check out XXXXX, too. XXXXX can use all the crazy network concurrency options of Rainbows! in a single worker process.
    back: Zbatery (http://rainbows.rubyforge.org/ and http://zbatery.bogomip.org/)
  - front: A website that mocks a slow API
    back: http://slowapi.com/ - e.g. curl http://slowapi.com/delay/1.0
  - front: Asynchronous HTTP Client (EventMachine + Ruby)
    back: em-http-request (https://github.com/igrigorik/em-http-request)
  - front: A HTTP client lib with a common interface over many adapters (e.g. Net::HTTP, Excon, EventMachine, etc), with a Rack-like middleware system
    back: Faraday (https://github.com/lostisland/faraday)
  - front: This command line tool from Apache benchmarks a server's response time
    back: ab -n 600 -c 200 http://mycoolasync.herokuapp.com/async_test
  - front: Fully async real-time web app Ruby framework. Built on top of EventMachine, designed for large number of open connections and providing full-duplex bidirectional communication.
    back: Cramp (http://cramp.in/)
  - front: What does full-duplex mean?
    back: It means transmitted data does not appear to be sent until it has actualy been received and acked by other party. 
  - front: What is the difference between a thread and a fiber?
    back: Thread execution can be interrupted at any time (preemption), possibly leaving data 
      an unsafe/unfinished state. Fibers are "cooperative", and cannot
      be preempted, and must explicitly yield to give up control.
  - front: The Reactor Pattern
    back: A single-threaded queue, all IO shoved into kernel thread,
      rejoin single-threaded reactor queue when it's done.
  - front: Python's Reactor pattern solution
    back: Twisted
  - front: Ruby's Reactor pattern solution
    back: EventMachine
  - front: Java's Reactor pattern solution
    back: JBoss_Netty
  - front: PHP's Reactor pattern solution
    back: Non-existent
  - front: Ruby library of convenience classes to untangle evented code,
      allowing you to write code in a non-callback-y manner.
    back: em-synchrony (https://github.com/igrigorik/em-synchrony)
  - front: OSS version of non-blocking (async) Ruby web server powering
      PostRank. Uses Ruby 1.9 fibers to de-callback-ify your code
    back: Goliath (http://postrank-labs.github.io/goliath/)
  - front: Nginx, Beanstalkd, EventMachine, Twisted, Node.js are all
      examples of servers that embrace this pattern
    back: Reactor pattern (http://www.igvita.com/2010/03/22/untangling-evented-code-with-ruby-fibers/)
  - front: What word describes the act of interrupting a task without
      its cooperation? How does this term apply to the various
      concurrency models?
    back: Preemption. Threads can be pre-empted (except user-space
      threads). Fibers cannot.
---

This is a half-finished journal. Most of the value lies in the fact that
there's a crap-ton of flashcards associated with what I learned.

## Unicorn `before_fork`, `after_fork`, and `preload_app`

In a Unicorn setting, shared resources like database connections 
need to be disconnected in Unicorn's `before_fork` hook and reconnected
in `after_hook`. This is so that you don't wind up in a situation where
two forked instances of your server try to write to a DB socket at the
same time, which can result in a Protocol Error. This makes sense; if 
two protocol-adhering processes write to the socket at the same time, 
the message delivered to the other side obviously won't adhere to the
protocol. TODO: at what point does this actually break? How bout writing
a quick Ruby script to prove this :) :) :)

Resources:

- https://devcenter.heroku.com/articles/concurrency-and-database-connections

## The difference between a process and a thread

A Process has:

- A group of resources
- A Thread of Execution

The group of resources includes:

- Address space where program text and data lives in memory
- Global variables
- Open files
- Child processes
- Pending alarms
- Signals and signal handlers
- Accounting information

A Thread (of Execution) has:

- Program counter
- Registers (of course these aren't shared b/w threads; that's crazy)
- Stack
- State

A Thread must execute in a Process, but they are separate entities.

There are multiple types of threads:

- User-space threads: super-fast thread switching because no kernel trap
  is required. Fine-grain control over thread scheduling. Unable to do
  blocking I/O though, since this blocks the entire process and all 
  user threads.
- Kernel-threads: can using blocking IO, defers scheduling to the OS,
  but each thread switch means a slow kernel trap, but then again if
  you're blocked by IO you're probably in the kernel anyway.
- Combined: multiple kernel threads have multiple userspace threads. 

Resources: 
  - http://stackoverflow.com/questions/200469/what-is-the-difference-between-a-process-and-a-thread/19518207#19518207
  - http://www.amazon.com/dp/0136006639/?tag=stackoverfl08-20
  - http://www.igvita.com/2010/03/22/untangling-evented-code-with-ruby-fibers/


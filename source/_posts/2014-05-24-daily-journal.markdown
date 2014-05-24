---
layout: post
title: "Daily Journal"
date: 2014-05-24 07:56
comments: true
categories: 
flashcards:
  - front: "Variable Timing"
    back: "Messaging, as opposed to synchronous communication (e.g. RPC/RPI), doesn't peg the sender's performance time on the receiver's performance time, e.g. a sender isn't just as fast as the receiver"
  - front: "Throttling"
    back: "RPC/RPI can overload a receiver if too many come in at the same time; messaging involves queues == throttling"
  - front: "Reliable Communication"
    back: "Storing the message means retrying, handling failures. "
  - front: "Disconnected Operation"
    back: "Offline apps can use messaging to queue data to sync when reconnected"
  - front: "Mediation"
    back: "Mediator pattern from GoF; if an app gets disconnected from others, it only needs to reconnect to the single messaging system"
  - front: "Thread Management"
    back: "Because async, threads no longer blocked on a response (unless they want / need to be)"
  - front: "CORBA"
    back: "Common Object Request Broker Architecture: a platform-neutral RPC spec"
  - front: "n-tier"
    back: "(multi-tier): client-server architecture in which presentation, application processing, and data management are physically separated; 3-tier is most common; some similarities w MVC? Also, n-tier is distribution, not integration."
---

### Enterprise Integration Patterns

Reading this here Fowler book.

Operating systems have begun to ship with messaging middleware and
related tools:

- Windows: MS Message Queueing (MSMQ), accessible via APIS like COM
  components and System.Messaging (part of .NET). 

Application Servers

- Java Messaging Service (JMS)

EAI (Enterprise Application Integration) suites:

- IBM WebSphere MQ
- Microsoft BizTalk
- TIBCO
- WebMethods
- SeeBeyond
- Vitria
- CrossWorlds

Many of the above include JMS as a supported client API, while
others focus on implementing merely JMS-compliant infrastructures.









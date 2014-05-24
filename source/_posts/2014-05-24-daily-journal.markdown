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
  - front: "git predecessor"
    back: "BitKeeper, no longer free of charge in 2005."
  - front: "git checksum"
    back: "SHA-1 hash"
  - front: "`git add` will store things in..."
    back: ".git/objects"
  - front: "3 locations for git config"
    back: "/etc/gitconfig, ~/.gitconfig, .git/config"
  - front: "git bakes this into your commits"
    back: "user.name and user.email"
  - front: "git config a.b.c lol"
    back: "puts [a "b"]\n  c = lol  in .git/config"
  - front: "what config is totally necessary to use git?"
    back: "user.name and user.email"
  - front: "git globs files"
    back: "so you can do git add log/\*.log"
  - front: "git log with diff"
    back: "git log -p (the p stands for patch)"
  - front: "git log limit to 2"
    back: "git log -2"
  - front: "difference b/w git author and committer"
    back: "author wrote the code, committer merged or applied to repo"
  - front: "can only push to this kind of git url"
    back: "SSH URL, e.g. git@github.com:machty/ember.js"
  - front: "command to display lots of live info about a remote"
    back: "git remote show origin"
  - front: "difference between lightweight and annotated tags"
    back: "lightweight just points to a commit; annotated are full git objects, checksummed, contain tagger name, message, can be GPG (GNU Privacy Guard) signed"
  - front: "how to annotate tag"
    back: "git tag -a v1.4 -m lol"
  - front: "command to inspect a tag for more info"
    back: "git show tagname"
  - front: "GPG signed tag"
    back: "git tag -s v3.0 -m haha"
  - front: "tag previous commit"
    back: "git tag v.retro shortsha"
  - front: "How many chars is a short sha?"
    back: "any number of chars so long as it can be matched to a longer one"
  - front: "how to push a single tag?"
    back: "git push tagname"
  - front: "how to add git auto complete"
    back: "you need bash, source gitrepo/contrib/completion/completion-something.bash"
  - front: "shorthand for declaring a git alias"
    back: "git config --global alias.something 'reset --HEAD'"
  - front: "what's in a git commit?"
    back: "pointer to snapshot, author, message, 0+ pointer to parent commits"
  - front: "HEAD"
    back: "pointer to the branch you're currently on"
  - front: "When can you fast forward?"
    back: "When the current branch head is an ancestor of the named commit. You're literally just moving a pointer."
  - front: "Upstream"
    back: "The originator of the data, which flowed to you at some point, e.g. when you cloned a repo, or you created a branch."
  - front: "What are the 3 components of a 3-way-merge?"
    back: "Common ancestor, current HEAD, and to-be-merged branch."
  - front: "What's unique about a merge commit?"
    back: "It has more than one parent."
  - front: "show all branches and last commit for each"
    back: "git branch -v"
  - front: "Show merged / unmerged branches"
    back: "git branch --merged ; git branch --no-merged"
  - front: "git push origin master expand to..."
    back: "git push origin refs/heads/master:refs/heads/master"
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

### Pro Git

#### VCS: Version Control System

Keeps patch sets between versions of files, reconstruct a version be
applying/unapplying patches. Example: `rcs`.

Git's predecessor was BitKeeper, whose free-of-charge status was
revoked in 2005.

#### git config

`git config lol.wat "imadork"`

will put the following into `./.git/config`:

    [lol]
      wat = imadork

what if you did `git config a.b.c lol` ?

    [a "b"]
      c = lol

followed by `git config a.b.z lol`:

    [a "b"]
      c = lol
      z = lol

So basically `git config` just prettily formats things into groups using
everything about the key you provide except the trailing segment. Makes
sense.

#### Staging

Staging means you're building up snapshots for a commit. By the time you
commit, you're just creating a commit object with meta data that points
to that same snapshot.


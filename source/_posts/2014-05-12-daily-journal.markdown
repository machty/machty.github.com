---
layout: post
title: "Daily Journal"
date: 2014-05-12 13:14
comments: true
categories: 
---


## Ruby `Module#===` 

Ran into [this piece of
code](https://github.com/hassox/warden/blob/master/lib/warden.rb#L33-L34) 
from the Warden repo: 

    def self.test_mode!
      unless Warden::Test::WardenHelpers === Warden
        Warden.extend Warden::Test::WardenHelpers
        Warden::Manager.on_request do |proxy|
          unless proxy.asset_request?
            while blk = Warden._on_next_request.shift
              blk.call(proxy)
            end
          end
        end
      end
      true
    end

I hadn't seen this usage of `===` before; I'm mostly familiar with it as
an unidiomatic alias of `is_a?`, e.g.:

    Array === []    #=> true
    [].is_a?(Array) #=> true

`#===` is the Case Equality operator or
[_subsumption_ operator](http://stackoverflow.com/questions/4527220/3-equals-or-case-equality-operator); 
it is overridden by subclasses to provide context-specific / semantic
meaning, for example:

- `Regexp === /asd/` #=> true
- `Fixnum === 5` #=> true
- `Object === {}` #=> true

Important things to keep in mind about `===`:

1. It is not commutative (A===B does not imply B===A)
2. It is a method of the object on the left side of an expression,
   e.g. `A===B` is shorthand for `A.===B` or `A.send(:===, //)`
3. It has nothing to do with equality; beware, JavaScripters.

ANYWAY: back to the Warden example: in this case, the `Module` class has
an instance method `===` that returns if the object on the right side
has extended the methods on the Module that `===` is called on, so:

    module M; end
    class Foo; end

    f = Foo.new
    M === f #=> false

    # reopen
    class Foo
      include M
    end

    M === f #=> true

So we turned `===` from false to true by including `M` on class `Foo`.
The Warden example is similar, except that the way the module's methods
were mixed in was via `extend` vs `include`. `extend` is a somewhat more
direct form of `include` in that it can be called on instances to put
methods directly on that instance, rather than having to open an
instance's class and add an `include` statement, which adds all of those
methods to subclasses. 

So when we check

      Warden::Test::WardenHelpers === Warden

this is the same as `WardenHelpers.=== Warden`, which translates to
"return true if Warden has all of WardenHelpers' methods". 







    





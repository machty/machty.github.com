---
layout: post
title: "SpreeCommerce meets Ember.js"
date: 2012-11-02 20:44
comments: true
categories: 
- spree
- ember.js
---

I'm working on a record label website in Ember.js with all sorts of
lovely dynamic goodies, infinite scrolling feeds, embedded music player,
blah blah blah, and most challengingly a full-on store where user's can
browse albums, shirts, whatevers, add them to their cart, and eventually
check out. This post covers a few lessons learned in getting a dynamic
JS website to play nicely with Spree, an open source e-commerce
framework.

Things you might learn from this article:
* Digging into gem source code
* Passing Javascript data in and out of iframes
* Converting non-prototype-extended data into prototype-extended data

<!--more-->

## Spree

[Spree](http://spreecommerce.com/) is an extensible e-commerce framework written
in Ruby-on-Rails that's been around for quite a number of years. Spree
follows the same pattern of CMS+front-end RoR plugins like
[RefineryCMS](http://www.refinerycms.com), where, in order to achieve
the desired customized design, the developer is encouraged to bend as
many rules as possible given the CMS design, and then when it comes to
breaking the rules, you're provided some mechanism of overriding/embellishing
the default source code, which usually takes one of two forms:

1. If you're overriding something like a view template, figure out the
   path of that view by digging through the Spree/Refinery source code
   and then duplicate that path in your `/app` directory, and if you've
   named the override correctly, the plugin will use your view rather
   than the stock default.
1. If you're overriding something like a model/controller, you use a
   decorator, wherein you run a `class_eval` on a the model/controller,
   say `Refinery::PagesController` in
   `app/decorators/controllers/refinery/pages_controller_decorator.rb`
   and define any of the overrides / extra methods you need.

Spree utilizes both of these methods, as well as a third method
seemingly absent from Refinery, which uses the
[Deface](https://github.com/railsdog/deface) gem to dig into raw
.erb files and replace certain chunks of it with your desired overrides.
It's basically a mechanism that allows you to override view's without
totally overwriting an .erb file, and, while messy in its own way,
allows your overrides to play nicely with other plugins' overrides if
you're careful enough to take a more conservative approach to the kinds
of overrides you make (e.g. add this partial after this elements rather
than then completely replace this giant ass element that all these other
plugins rely on as an anchor).

That's enough of an overview. The rest of this post is how I managed to
use chunks of Spree to build my own Ajax-y store for a record label
website.

## Maintaining am AJAX Shopping Cart

By default, vanilla Spree doesn't provide you any AJAX functionality;
every action, from viewing a product to adding it to your cart causes a
full page refresh, so getting it to work in an AJAX fashion takes a bit
of finesse. Step 1 is finding the appropriate controller actions that
you need to override. The first thing I wanted to override was adding a
product to a cart. The easiest way to figure out how to do this was to
navigate to my local server hosting a sample Spree website and add a
product to my shopping cart while observing `log/development.log` in my
Rails app folder:

{% codeblock %}
$ : tail -F log/development.log

// Add an item to the shopping cart from the browser

Started POST "/store/orders/populate" for 127.0.0.1 at 2012-11-02 21:48:41 -0400
Processing by Spree::OrdersController#populate as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"6kdui/lTyLCBTSZTsEQAR1UgUxyqaY8mhBaUouwjhXA=", "products"=>{"12"=>"45"}, "quantity"=>"1"}
...
{% endcodeblock %}

Ah hah, the controller that handles adding items to the shopping cart is
`Spree::OrdersController` and the action is `populate`. Now all I have
to do is figure out a way to modify that controller action to accept
AJAX requests and spit out a JSON response of the updated state of the
cart so that I can display the contents of the cart from my Ember site.

This means you have to start digging into the Spree source code.
Whenever I need to dig into the source code of a plugin I'm using (which
is pretty much all the damn time) I either go to the plugin's github
page and search through the directory (or press `t` on the homepage and
fuzzy search) or, most often, I just `git clone` the repository so I can
have the whole project locally to inspect and prod. I find a file called
`orders_controller.rb`, and here's an excerpt of its `def populate`
block:

{% codeblock lang:ruby %}
      fire_event('spree.cart.add')
      fire_event('spree.order.contents_changed')
      respond_with(@order) { |format| format.html { redirect_to cart_path } }
    end
{% endcodeblock %}

Balls, they've got it hard-wired in there to respond only to `html`
requests. How so? Because in the `respond_with` block, they only
specify what should happen when the format of the incoming request is
html, rather than, say, json or xml or any of the other kinds of
requests that can come in. This is problematic for us since we want to
use this function so that it can handle JSON requests from our
JavaScript app. I don't know how to do this other than rewriting the
entire function to eventually respond with JSON. Perhaps Railscasting
Ryna Bates or Yehuda Katz could think of a way to do this, but have no
idea how something like that would be accomplished, so let's just go the
obvious route and override that entire function so that it'll respond to
our JS app's JSON AJAX requests.

### Using Decorators to Override Spree Controllers

We need to override the `populate` function of the spree controller to
return JSON. To do this, you have to use a 'decorator'. The term
'decorator' is used in a lot of different contexts in the programming
world, but most generally, it implies that you'll be decorating an
underlying class with more methods (or, in this case, overriding a
method entirely). So let's create our decorator for the
`OrdersController` in `app/controllers/orders_controller_decorator.rb`.
In this file, we'll use `class_eval` to reopen the class and override
the `populate` method so that it returns the JSON we need. And exactly
what JSON do we need? Well, we do want our our Ember app to properly
display updates to the shopping cart as they come in, and what better
way to get an updated state of the shopping cart other than right when
we add items to it? 

For this reason we `render json: current_order` after we've added an
item to the cart. Our `orders_controller_decorator.rb` looks something
like this:

{% codeblock lang:ruby %}
Spree::OrdersController.class_eval do
  def populate
    @order = current_order(true)

    #...

    fire_event('spree.cart.add')
    fire_event('spree.order.contents_changed')
    respond_with(@order) do |format|
      format.html { redirect_to cart_path }
      format.json { render json: current_order } # <----
    end
  end
end
{% endcodeblock %}

### Storing Cart Updates in Ember.js

This part's pretty straight-forward. We use a controller to maintain the
state of the cart. It's initially populated on page load by the current
value of the cart (an easy exercise to figure out once you understand
the general techniques applied in this article).

The important thing to pay attention to here is that in the `success`
handler in the Ajax call, we take the `current_order` JSON returned from
our modified `populate` action and save it to the controller, so that
anything that's bound to the controller's cart properties get
automatically updated.

{% codeblock lang:coffeescript %}
App.CartController = Em.ObjectController.extend
  content: window.cart

  saving: false

  addItem: (variantId, quantity, callback) ->

    variants = {}
    variants[variantId] = quantity

    @set 'saving', true

    $.ajax '/add_item.json',
      type: 'POST'
      data:
        variants: variants
      success: (data) =>
        @set 'content', data
        callback(true) if callback
      error: (data) ->
        alert "Error adding item to Shopping Cart. Please try again."
        callback(false) if callback
      complete: =>
        @set 'saving', false
{% endcodeblock %}

### Checkout

Ok, adding items to the cart is easy enough (note that I'm skipping over
the easier parts, like querying the server for products and displaying
them with Handlebars templates), but what about the checkout phase?

Well, I don't have the gumption to re-tool Spree to work in an Ember.js
setting. Maybe someday I'll write the gem for that, but not today.
Today, we'll just use an iFrame to display the normal checkout page
that's included with Spree. To do this, you'll create a new route in
your router called `checkout` which connects outlets to a view that has
an iFrame in it pointing to `/store/checkout/address` (address just
happens to the first page of checkout, i.e. billing and shipping
address). The rest mostly just works out of the box, but there is one
last thing we need to get working, which is, how do we notify the Ember
portion of our app that the shopping cart has been cleared after the
user has made a purchase?

We'd like our Ember.js shopping cart to immediately empty once the
user's made a successful purchase. We could just randomly poll the
server to sync the state of the cart, but that's a little messy and
resource intensive. Arguably a better way to go would be to have the
iframe pass its parent Ember.js app information about the state of the
cart at each page load, so that for every page of the checkout, you
re-flash the shopping cart, and when you've successfully checked out,
you flash the shopping cart with an empty cart, and that's how your
Ember.js app knows the shopping cart's been paid for. 

### Deface

To do this, we'll add a Deface override to inject some Javascript at the
top of every Spree page. This Javascript will attempt to grab the
`current_order`, if it exists, serialize it, and pass it to the parent
frame, if it exists. The Deface override looks like this:

{% codeblock lang:ruby %}
Deface::Override.new(:virtual_path => "spree/layouts/spree_application",
                     :name => "cart_updater",
                     :insert_bottom => "[data-hook='inside_head']",
                     :partial => "store_overrides/cart_updater")
{% endcodeblock %}

This can reside in `app/overrides/overrides.rb`. Basically, this says
that we're overriding the Spree template in the Spree source code at
`spree/layouts/spree_application` by inserting the `cart_updater`
partial at the bottom of the `inside_head` data hook in the
`spree_application.erb.html` template.

Now we'll need to
create the `cart_updater` that's referenced. We'll do that by creating a
file called `app/store_overrides/_cart_updater.html.erb`, which looks
something like this:

{% codeblock lang:html %}
<script type="text/javascript">

if(window.parent && window.parent.shopCallback)
{
  var cart;
  <% if current_order %>
    cart = <%= OrderSerializer.new(current_order).to_json.html_safe %>;
  <% else %>
    cart = <%= nil.to_json.html_safe %>;
  <% end %>

  window.parent.shopCallback(cart);
}

</script>
{% endcodeblock %}

This chunk of code passes a serialized order to the parent page, if it
exists. Now all we need to do is add the `shopCallback` function.

### Prototype Extension Gotcha

Jumping a bit ahead, here's the code for the `window.shopCallback`
function. 

{% codeblock lang:coffeescript %}
window.shopCallback = (cartJson) ->
  # Have to $.extend to reconstruct object in Emberized environment
  # so that we get prototype extensions on the arrays.
  Chimera.router.set('cartController.content', $.extend(true, {}, cartJson))
{% endcodeblock %}

Note that we don't just set `content` to `cartJson`, but rather to
`$.extend(true, {}, cartJson))`. Why is this? Well, prepare yourself for
a bizarre corner-case that you'll occasionally have to be on your guard
against. The problem stems from the fact that `cartJson` is created
within the iframe context, which knows nothing about Ember, and then
`cartJson` is passed to the parent Emver.js page. One of the things the
Ember.js library adds by default are a bunch of prototype overrides for
the Array, String, and probably Object types. These prototype extensions
allow properties of these objects to be observable, among other many things,
but the `cartJson` object coming from the iframe doesn't have that
prototype extension, since it's prototypes come from the unembellished
iframe context. If you just set `cartController.content` to `cartJson`,
you'll very quickly run into bizarre errors about certain
properties/functions not being defined on `cartJson`. 

The solution to this is to recreate the `cartJson` in the
prototype-extended Ember.js context. A neat technique for doing this,
which I learned from `gavacho` from the emberjs IRC, is to use the
jQuery extend function, which can be used in a lot of different
instances, but in this case, we're using it to make a deep copy of the
`cartJson` object. This recreates the object so that it'll have the
prototype extensions that Ember expects.

I think that does it for this article. Let me know if you have any
questions, and always always check out the Ember IRC and StackOverflow
for some smart dude(tte)s ready to helpy you at your every turn.

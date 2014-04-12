---
layout: post
title: "Rake Pipeline Filter for Syncing with Client-Managed Static Site"
date: 2012-12-29 17:47
comments: true
categories: 
- rake pipeline
- nokogiri
---

Just rolled out a quick [single-pager for my bandmate](http://megancoxmusic.com/),
which is just a super simple static site that she'll be updating herself
via FTP. Problem is, at some point in the future I'll be called upon to
make some change to the JS, or the player widget, or something messy
enough that my non-developer client would be rightfully reluctant to fidget with.
If she updates the headers or the paragraph descriptions, and I want to
make changes to the rest of the page, I'll have to go through the
annoying process of copying her raw HTML modifications into my freshly
regenerated local HTML.

<!--more-->

## Rake Pipeline

I built this extremely simple site using 
[Rake Pipeline](https://github.com/livingsocial/rake-pipeline), which is
a Ruby-based asset pipeline that maps input files to output files, and
lets you determine all the processing filters used to generate all the
output files. So, you can quickly throw in a Sass or CoffeeScript
filter to generate CSS/JS, and then concatenate your files together,
rename them, ompress them, etc. etc. Most of the filters you'd ever
want for anything web-related can be found in
[this gem](https://github.com/wycats/rake-pipeline-web-filters).

You can also very easily define your own filters if the above gem
doesn't cover your needs, which is exactly what I did to handle the
problem of syncing/merging changes made directly to HTML via FTP by my client
and the changes I'd be making the the original input code. 

## Custom Filter using Nokogiri

I agreed with my client that she should only make changes within 
`<div class="content">`s. This makes it so that all I need to do to sync
her changes with mine is take my Rake Pipeline-generated HTML and
replace _its_ content div with the content div from her FTP-updated
HTML. [Nokogiri](http://nokogiri.org/) is just the HTML-processing tool
for such a job.

The code is simple enough: 
[check out the gist](https://gist.github.com/4409814).

What it does is:

1. Determine the remote URL of the already-published file based on
   a `host` parameter passed into the filter and the relative path
   of the file at that point in the pipeline (which means if part of
   your processing involves changing the output filename of the HTML
   file (e.g. from `html/index.haml` to `index.html`) you'll want to
   invoke this filter after any output-path-changing filters.
1. Download the remote file and parse it for content using CSS selectors
   passed into the filter (this is what the Nokogiri gem does).
1. Parse the input file for the same CSS selectors and replace it with
   the remote file's selected content.

(This is kind of similar to how some AJAX sites update content:
the server will render some hidden HTML, and the success handler will
loop through all the root level elements rendered and replace 
similarly-classed or id'd elements on the visible page with what the
server returned.)

### Convenience Method

You'll notice this at the bottom of the gist:

{% codeblock lang:ruby %}
Rake::Pipeline::DSL::PipelineDSL.module_eval do
  def remote_replace(*args, &block)
    filter(RemoteReplaceFilter, *args, &block)
  end
end
{% endcodeblock %}

This makes it possible to use

{% codeblock lang:ruby %}
  remote_replace "http://www.megancoxmusic.com/new2/", ".content"
{% endcodeblock %}

in your Assetfile instead of the more verbose

{% codeblock lang:ruby %}
  filter(RemoteReplaceFilter, "http://www.yourstaticsite.com/root_of_content", ".content")
{% endcodeblock %}

### Skipping the filter while running `rakep server`

You can run `rakep server` to launch a Rack-based server the hosts the
output files specified by your `Assetfile`. This is much more convenient
than running `rakep build` every time you want to test a change to your
input files. That said, if you're developing without an internet
connection, or you have lots of files to sync, you can skip this 
(potentially slow) filter
by adding `unless defined?(::Rake::Pipeline::Server)` to the end of your
`remote_replace` statement. The reason this works is that the file
containing `Rake::Pipeline::Server` only gets required when `rakep
server` is run.

### Whoops

I ended up making the filter depend on the 
[rake-pipeline-web-filters gem](https://github.com/wycats/rake-pipeline-web-filters)
so that I could use their
`Rake::Pipeline::Web::Filters::FilterWithDependencies` module for
making sure `nokogiri` was properly required in the `Gemfile`. Except,
now I realize that was kind of silly, since my little custom filter
isn't part of any larger collection of web filters where it'd be important not
to require all the filters' dependencies by default. Whoops. But, should
this be a sensible fit for the web-filters gem (it's not) it shall be
ready. Consider it an understudy last in line.




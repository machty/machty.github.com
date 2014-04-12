---
layout: post
title: "Transferring S3-Enabled Heroku Apps Between Dev/Staging/Prod"
date: 2012-11-05 00:01
comments: true
categories: 
- heroku
- S3
- Rails
---

You know, I could just write this in my Evernote and reference as
needed, but I'm writing it here, because I love you. But I'm in a hurry.

Here are the steps I take for transferring apps from my development
server to Heroku staging/production servers, which can get somewhat
complicated if Amazon S3 is involved.

<!--more-->

### Database

You've already pushed your code to Heroku. That's the easy part. Now for the
database:

{% codeblock %}
rvm use 1.9.2
heroku db:push
{% endcodeblock %}

`heroku db:push` uses `taps` to serialize and transmit all of your dev
database to the Heroku database. We rvm to Ruby 1.9.2 because Ruby 1.9.3
has mad issues serializing Datetimes. I think it was datetimes.
Something involving Psych. Anyway, just use 1.9.2.

### S3

Let's assume you've started building the app/site using your own S3
bucket because you didn't want to wait for your client to get their
Amazon AWS account up and running. Now you need to take all the stuff
uploaded to your S3 bucket and move it to your client's bucket. This is
a scoatch tricky, but we shall prevail.

First, log into your client's AWS account and go to S3. Create the
bucket you'll be using, then open the bucket's properties, and click 
`Add Bucket Policy`. Then paste in this, replacing the ALL CAPS 
BUCKETNAME with the production bucket name you'll be using:

{% codeblock %}
{
     "Version": "2008-10-17",
     "Statement": [
          {
               "Sid": "AllowPublicRead",
               "Effect": "Allow",
               "Principal": {
                    "AWS": "*"
               },
               "Action": "s3:GetObject",
               "Resource": "arn:aws:s3:::BUCKETNAME/*"
          }
     ]
}
{% endcodeblock %}

The purpose of this is to prepare for the next step, in which we'll be
pasting a bunch of files into this bucket, and we want them to go in
with public-read access rather than the default of, well, zero access
for anybody, ever, including the admin. If you think I'm going about
this wrong way, Disqus me them comments, but I don't think there's an
easier way.

Second, let's copy your dev buckets to disk. Download/open 
[3hub](http://www.3hubapp.com/), and put in your
dev S3 account credentials, log in, select your dev bucket, and drag and
drop your root-level files to your desktop. Now take a 3 minute nap.

Wake up, grab a brush and put a little make up, then disconnect 3hub
from your dev account and log into your client's S3 account, and drag
those downloaded files from your desktop to your client's bucket. 5
minute nap. You've earned it. Now all your S3 files have been
transferred and have proper access permissions, thanks to your magic
bucket policy incantation.

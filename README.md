The MacroDeck Platform
======================

The MacroDeck platform is a library for Ruby that works with [CouchRest][1] to
provide a semi-schemaless database layout. Semi-schemaless means that CouchDB
doesn't enforce a schema, but we do. Documents have a distinct type and each
type corresponds to a different object. An event and a place are similar and
related, but we can't just have fields on there all willy-nilly :). 

[1]: http://github.com/couchrest/couchrest

License
=======

This library is licensed under the [GNU General Public License, version 2.0][2]
or later (at your option), with the exception that [Poseidon Imaging][3]
retains all copyright and can sublicense any code.

Please do not submit patches unless you agree to these terms.

[2]: http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
[3]: http://www.poseidonimaging.com/

Startup
=======

To start the MacroDeck platform, put this in your config/environments/`name`.rb
file:

    MacroDeck::Platform.start!("database-name")

You can call it whatever, or even load it from database.yml. Since this library
does not depend on Rails, this doesn't happen automatically. Patches welcome
for code that automatically determines if Rails is being used and adds magic if
so.

Tests
=====

I haven't been good about adding tests in the past - so suggestions are
definitely welcome. This library will hopefully be very well tested by the
time it gets put into production.

Attachment Plan
===============

Here's some bullet points for how I think that we should implement attachments.
It would be nice to be able to leverage Paperclip, but I think that given the
fact that the MacroDeck Platform is very disconnected from ActiveRecord, it would
probably take more work to make Paperclip work than it would be to implement
something that sends files off to S3 and keeps track of where they are.

* Use `right_aws` gem.
* Allow the bucket name to be configured somehow by the hosting application.
  Probably in a similar way to how the platform chooses a database name?
* [Get a RightAws::S3::Bucket instance][4]. Should this be initialized when the
  platform boots? Probably?
* Determine a standard naming convention. /attachments/Class/id/attachmentname.ext
  works for me. The attachment name probably needs to be randomly selected,
  maybe another UUID?
* An object should probably support many attachments.
* Not sure how to use RightAWS to generate a temporary link (needs research).
* Can use `bucket.key(path).public_link` but this doesn't make a temporary link
  (so anyone who knows the URL can get the attachment... though if the filenames
  are UUIDs, maybe this is OK)
* It appears that there's something like `interface.get_link` that allows you to
  specify a bucket name, key, and validity duration. This could work.

[4]: http://rubydoc.info/github/rightscale/right_aws/master/RightAws/S3:bucket

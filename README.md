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
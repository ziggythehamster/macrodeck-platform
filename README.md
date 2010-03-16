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

To start the MacroDeck platform, put this in your environments/`name`.rb file:

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

Base Classes
============

DataObjectDefinition
--------------------

Properties

 * `_id`: Since there are a finite number of data object definitions, this
   should be "`object_type`-definition".
 * `type`: `DataObjectDefinition`
 * `object_type`: The type of the object we're defining. Will be Place, City,
   State, etc.
 * `fields`: An array whose format is as follows:
       [ [ "field_name", "Class", is_required ], ... ]
   Obviously, `is_required` will be true if the field is required, false
   otherwise. Think of it as if it were the same as NULL/NOT NULL
 * `validations`: An array whose format is as follows:
       [ [ "validation_name", ARGV ], ... ]
   `validation_name` is the name of the validation, and ARGV is the argument
   to pass to the validation. We will be implementing [Validatable][4], which
   is very similar to ActiveRecord's validations.

[4]: http://validatable.rubyforge.org/

Map/Reduce functions

 * `by_object_type-map`: Returns the `object_type` as the key and the document
   as the value.

DataObject
----------

Properties

 * `_id`: Assigned by CouchDB though should be specific to each class. A Place
   might use the ID assigned by GeoAPI whereas an Event might just stick to
   using the default.
 * `type`: The type of the object. Must point at an `object_type` defined by a
   `DataObjectDefinition`. This will be Place, City, etc.
 * `parent`: The document ID of the object's parent. `null` if no parent.
 * `title`: A title for the data object. Will be the summary for an event, the
   name of a city for a city, and so on.
 * `description`: An optional description for the data object. Usually will be
   filled in by an end user.
 * `tags`: An array of tags. `[ "chunky", "bacon" ]`
 * The fields defined in the `DataObjectDefinition`'s `fields`.

Map/Reduce functions

 * `by_type-map`: Key returned is the object's `type`, value is the document.
   The purpose is to allow searching for all Cities, for example.
 * `by_tags-map`: Key returned is a tag, value returned is the document.
 * `by_parent-map`: Key returned is the parent's ID, value is the document.
   Used to traverse the tree.
 * Others not yet defined but likely will need to be. Ideas might be to have a
   standard way to store geographic locations and then index that. Though I
   haven't found a good way to store geographic coordinates yet.

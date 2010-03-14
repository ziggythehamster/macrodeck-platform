The MacroDeck Platform
======================

The MacroDeck platform is a library for Ruby that works with [CouchRest][1] to
provide a semi-schemaless database layout. Semi-schemaless means that CouchDB
doesn't enforce a schema, but we do. Documents have a distinct type and each
type corresponds to a different object. An event and a place are similar and
related, but we can't just have fields on there all willy-nilly :). 

[1]: http://github.com/couchrest/couchrest

Base Classes
============

`DataObjectDefinition`
----------------------

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
   to pass to the validation. We will be implementing [Validatable][2], which
   is very similar to ActiveRecord's validations.

[2]: http://validatable.rubyforge.org/

Map/Reduce functions

 * `by_object_type-map`: Returns the `object_type` as the key and the document
   as the value.

`DataObject`
------------


ag-magic-model
========

[![Build Status](http://img.shields.io/travis/AppGyver/ag-magic-model/master.svg)](https://travis-ci.org/AppGyver/ag-magic-model)
[![NPM version](http://img.shields.io/npm/v/ag-magic-model.svg)](https://www.npmjs.org/package/ag-magic-model)
[![Dependency Status](http://img.shields.io/david/AppGyver/ag-magic-model.svg)](https://david-dm.org/AppGyver/ag-magic-model)
[![Coverage Status](https://img.shields.io/coveralls/AppGyver/ag-magic-model.svg)](https://coveralls.io/r/AppGyver/ag-magic-model)

Sprinkle Supersonic Data models with magical Composer Module sauce

## Usage

```coffeescript
# Replace this:
Car = supersonic.data.model 'car'

# With this:
magical = require 'ag-magic-model'
Car = magical 'car'

# Bam, your model is now magical!
```

Once sprinkled on a `supersonic.data.model` class, `ag-magic-model` adds the `magical` property on the class. It can be used to access features enabled when integrating with Composer.

## Magical model accessors

### `Model.magical.name`

Access the plain name of the resource this model is backed by.


### `Model.magical.definition`

Access the complete definition object from Composer used by this model.


### `Model.magical.label[fieldName]`

Access the formatted label of a field.


### `Model.magical.routes`

Access route strings usable as `supersonic.module` navigation functionality parameters, eg. `supersonic.module.modal.show`.

- `Model.magical.routes.new`: route for creating a new record of this type


### `Model.magical.titles`

#### `Model.magical.titles.plural`

The plural title for a collection of records of this type.

#### `Model.magical.titles.singular`

The singular title for records of this type.

#### `Model.magical.titles.record(data)`

The formatted title for a specific record of this type.


### `Model.magical.formatter[fieldName]`

Access the formatter function for a field. Call the function with a field value to get it back as formatted.

Formatting takes into account the field's type, and possible other configuration options defined in Composer. For instance, a field with they display type `date` will be formatted as `YYYY-MM-DD` by default, but this can be overridden by configuring the data field in Composer.


### `Model.magical.relations`

**NOTE:** Records and collections fetched via `Model.magical.relations.join` are *read only*. It is not appropriate to `save()` such records: they have gotten their fields tampered with, and the underlying resource does not know how to map the joined contents back to their normalized representations.

#### `Model.magical.relations.join(fields...).all(query)`

Get a followable of `all` records such that they will get the contents of enumerated `fields` listed joined in asynchronously. For example:

    Model.magical.relations
        .join('foo', 'bar')
        .all()
        .changes
        .onValue (record) ->
            console.log {
                foo: record.foo.title
                bar: record.bar.title
            }

For a relation field, a field `foo` containing the id `123` will be replaced with:

    id: 123
    title: <the title for 123 rendered as a string>
    record: <the Model instance for 123>

For a multirelation field `foos` with `123` and `456`:

    [
        {
            id: 123
            title: <the title for 123 rendered as a string>
            record: <the Model instance for 123>
        }
        {
            id: 456
            title: <the title for 456 rendered as a string>
            record: <the Model instance for 456>
        }
    ]

Because the join is done asynchronously, the contents will start as having a placeholder for the `title` and nothing for `record`.

#### `Model.magical.relations.join(fields...).one(id)`

Get a followable of `one` record by id such that it will get the contents of enumerated `fields` listed joined in asynchronously. Works as `join().all()`, above.

#### `Model.magical.relations.related(field).many(ids)`

Get a followable of `many` records loaded by `ids` as a collection of related records that will get their contents asynchronously.

    Model.magical.relations
        .related('foo')
        .many([123, 456])
        .changes
        .onValue (collection) ->
            console.log collection

The collection's signature is the same as with `Model.magical.relations.join`.

#### `Model.magical.relations.related(field).one(id)`

Get a followable of `one` record loaded by `ids` such that it will get its contents asynchronously.

The record's signature is the same as with records from `Model.magical.relations.join`.

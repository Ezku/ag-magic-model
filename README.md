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

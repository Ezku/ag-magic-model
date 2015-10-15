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

Once sprinkled on a `supersonic.data.model` class, `ag-magic-model` adds the `magical` property on the class and its instances. It can be used to access features enabled when integrating with Composer.

### Magical model accessors

#### `Model.magical.name`

Access the plain name of the resource this model is backed by.

#### `Model.magical.label[fieldName]`

Access the formatted label of a field.

### Magical record accessors

#### `record.magical.title`

Access the formatted title of a data record.

#### `record.magical.formatted[fieldName]`

Access the value of a field formatted as a string.

Formatting takes into account the field's type, and possible other configuration options defined in Composer. For instance, a field with they display type `date` will be formatted as `YYYY-MM-DD` by default, but this can be overridden by configuring the data field in Composer.


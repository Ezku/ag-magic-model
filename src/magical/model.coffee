labels = require './labels'
formattedFieldAccessors = require './formatted-field-accessors'

sprinkleMagicProps = (object, getProps) ->
  Object.defineProperty object, 'magical',
    enumerable: false
    get: getProps

module.exports = magical = (ModelClass, schema, modelName) ->
  class MagicalModel extends ModelClass

  sprinkleMagicProps MagicalModel, ->
    name: modelName
    label: labels ModelClass, schema

  sprinkleMagicProps MagicalModel.prototype, ->
    formatted: formattedFieldAccessors schema, this

  MagicalModel

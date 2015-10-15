labels = require './labels'
createFormatters = require './formatters'

formattedFieldAccessors = require './formatted-field-accessors'

sprinkleMagicProps = (object, getProps) ->
  Object.defineProperty object, 'magical',
    enumerable: false
    get: getProps

module.exports = magical = (ModelClass, schema, modelName) ->
  class MagicalModel extends ModelClass

  schemaFields = schema.fields || {}
  formatters = createFormatters schemaFields

  sprinkleMagicProps MagicalModel, ->
    name: modelName
    label: labels ModelClass, schemaFields
    formatter: formatters

  sprinkleMagicProps MagicalModel.prototype, ->
    formatted: formattedFieldAccessors formatters, this

  MagicalModel

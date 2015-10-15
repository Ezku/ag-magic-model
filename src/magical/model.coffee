labels = require './labels'
createFormatters = require './formatters'

formattedFieldAccessors = require './formatted-field-accessors'
titleAccessor = require './title'

sprinkleMagicProps = (object, getProps) ->
  Object.defineProperty object, 'magical',
    enumerable: false
    get: getProps

module.exports = magical = (ModelClass, definition, modelName) ->
  class MagicalModel extends ModelClass

  schema = definition.schema || {}
  schemaFields = schema.fields || {}
  formatters = createFormatters schemaFields

  sprinkleMagicProps MagicalModel, ->
    name: modelName
    definition: definition
    label: labels ModelClass, schemaFields
    formatter: formatters

  # KLUDGE: Because we can't affect which class the underlying model will new
  # models off of, directly sprinkle on top of the original prototype. This is
  # the ugly, magical part.
  sprinkleMagicProps ModelClass.prototype, ->
    formatted: formattedFieldAccessors formatters, this
    title: titleAccessor definition, formatters, this

  MagicalModel

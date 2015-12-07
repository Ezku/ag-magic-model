labels = require './labels'
createFormatters = require './formatters'
titleAccessors = require './titles'

sprinkleMagicProps = (object, getProps) ->
  Object.defineProperty object, 'magical',
    enumerable: false
    get: getProps

module.exports = magical = (createMagicModel, ModelClass, definition, modelName) ->
  class MagicalModel extends ModelClass

  schema = definition.schema || {}
  schemaFields = schema.fields || {}
  formatters = createFormatters createMagicModel, schemaFields

  sprinkleMagicProps MagicalModel, ->
    name: modelName
    definition: definition
    label: labels ModelClass, schemaFields
    formatter: formatters
    titles: titleAccessors definition, formatters

  MagicalModel

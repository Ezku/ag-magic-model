labels = require './labels'
createFormatters = require './formatters'
titleAccessors = require './titles'

sprinkleLazyMagicProps = (object, propGetters) ->

  props = {}
  for propName, propGetter of propGetters
    Object.defineProperty props, propName, {
      enumerable: true
      get: propGetter
    }

  Object.defineProperty object, 'magical', {
    enumerable: false
    get: -> props
  }

lazy = (f) ->
  value = null
  () ->
    value ? (value = f())

module.exports = magical = (createMagicModel, ModelClass, definition, modelName) ->
  class MagicalModel extends ModelClass

  schema = definition.schema || {}
  schemaFields = schema.fields || {}

  formatters = lazy -> createFormatters createMagicModel, schemaFields

  sprinkleLazyMagicProps MagicalModel, {
    name: -> modelName
    definition: -> definition
    formatter: formatters
    label: lazy -> labels ModelClass, schemaFields
    titles: lazy -> titleAccessors definition, formatters()
  }

  MagicalModel

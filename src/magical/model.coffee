memoize = require 'memoizee'

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

module.exports = magical = (createMagicModel, ModelClass, definition, modelName) ->
  class MagicalModel extends ModelClass

  schema = definition.schema || {}
  schemaFields = schema.fields || {}

  formatters = memoize -> createFormatters createMagicModel, schemaFields

  sprinkleLazyMagicProps MagicalModel, {
    name: -> modelName
    definition: -> definition
    label: memoize -> labels ModelClass, schemaFields
    formatter: formatters
    titles: memoize -> titleAccessors definition, formatters()
  }

  MagicalModel

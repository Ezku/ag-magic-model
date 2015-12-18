labels = require './labels'
createFormatters = require './formatters'
titleAccessors = require './titles'
routeAccessors = require './routes'
relationAccessors = require './relations'

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

module.exports = magical = (createMagicModel, ModelClass, definition, modelName, routes) ->
  class MagicalModel extends ModelClass

  schema = definition.schema || {}
  schemaFields = schema.fields || {}

  formatters = lazy -> createFormatters createMagicModel, schemaFields
  titles = lazy -> titleAccessors definition, formatters()

  sprinkleLazyMagicProps MagicalModel, {
    name: -> modelName
    definition: -> definition
    formatter: formatters
    titles: titles
    label: lazy -> labels ModelClass, schemaFields
    routes: lazy -> routeAccessors modelName, routes
    relations: lazy -> relationAccessors createMagicModel, ModelClass, modelName, titles(), definition
  }

  MagicalModel

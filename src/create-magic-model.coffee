memoize = require 'memoizee'

makeMagicalModel = require './magical/model'

memoizeWithDynamicArguments = (f) ->
  memoize f, {
    length: false
  }

module.exports = ({createModel, getResourceDefinition, routes }) ->

  createMagicModel = memoizeWithDynamicArguments (modelName, args...) ->
    Model = createModel modelName, args...
    resourceDefinition = getResourceDefinition modelName

    makeMagicalModel(
      createMagicModel
      Model
      resourceDefinition
      modelName
      routes
    )


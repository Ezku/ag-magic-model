memoize = require 'memoizee'

makeMagicalModel = require './magical/model'

module.exports = createMagicModel = ({createModel, getResourceDefinition}) ->

  memoize (modelName, args...) ->
    Model = createModel modelName, args...
    resourceDefinition = getResourceDefinition modelName

    makeMagicalModel(
      createMagicModel
      Model
      resourceDefinition
      modelName
    )


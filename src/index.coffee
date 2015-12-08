memoize = require 'memoizee'

makeMagicalModel = require './magical/model'

createModel = window?.supersonic?.data?.model ? ->
  class EmptyModel

getResourceDefinition = (modelName) ->
  window?.supersonic?.env?.data?.bundle?.resources[modelName] ? {}

module.exports = createMagicModel = memoize (modelName, args...) ->
  Model = createModel modelName, args...
  resourceDefinition = getResourceDefinition modelName

  makeMagicalModel(
    createMagicModel
    Model
    resourceDefinition
    modelName
  )


makeMagicalModel = require './magical/model'

createModel = window?.supersonic?.data?.model ? ->
  class EmptyModel

getSchema = (modelName) ->
  window?.supersonic?.env?.data?.bundle?.resources[modelName]?.schema ? {}

module.exports = createMagicModel = (modelName, args...) ->
  Model = createModel modelName, args...
  schema = getSchema modelName

  makeMagicalModel(
    Model
    schema
    modelName
  )


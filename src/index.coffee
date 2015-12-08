
module.exports = require('./create-magic-model')(
  createModel: window?.supersonic?.data?.model ? ->
    class EmptyModel
  getResourceDefinition: (modelName) ->
    window?.supersonic?.env?.data?.bundle?.resources[modelName] ? {}
)

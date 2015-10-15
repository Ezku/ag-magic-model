labels = require './labels'

sprinkleMagicProps = (object, props) ->
  Object.defineProperty object, 'magical',
    enumerable: false
    get: ->
      props

module.exports = magical = (ModelClass, schema, modelName) ->
  class MagicalModel extends ModelClass

  sprinkleMagicProps MagicalModel, {
    name: modelName
    label: labels ModelClass, schema
  }

  sprinkleMagicProps MagicalModel.prototype, {}

  MagicalModel

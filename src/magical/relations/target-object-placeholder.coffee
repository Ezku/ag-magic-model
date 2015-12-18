Bacon = require '../../external/Bacon'

module.exports = targetObjectPlaceholder = (relationTargetModel, relatedObjectId) ->
  Bacon.once {
    id: relatedObjectId
    title: "« loading related #{relationTargetModel.magical.titles.singular} »"
  }


module.exports = targetObjectUpdates = (relationTargetModel, relatedObjectId, renderRelationTitle) ->
  relationTargetModel
    .one(relatedObjectId)
    .changes
    .map (relatedObject) ->
      id: relatedObject.id
      title: renderRelationTitle relatedObject
      record: relatedObject

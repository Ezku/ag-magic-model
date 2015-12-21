debug = require('debug')('ag-magic-model:relations:related-field-loader')

module.exports = relatedFieldLoader = (relationTarget) ->

  { relationTargetModel, renderRelationTitle, relationType } = relationTarget

  whereIdIn = (ids) ->
    # FIXME: Why '_id'? Does this hold for all resource types, all sources?
    query: JSON.stringify
      _id:
        $in: ids

  one: (relatedObjectId) ->
    debug "Related #{relationTargetModel.magical.titles.singular}:", relatedObjectId

    relationTargetModel
      .one(relatedObjectId)
      .changes
      .map((relatedObject) ->
        id: relatedObject.id
        title: renderRelationTitle relatedObject
        record: relatedObject
      )
      .startWith({
        id: relatedObjectId
        title: "« Loading related #{relationTargetModel.magical.titles.singular} »"
      })

  many: (relatedObjectIds) ->
    debug "Related #{relationTargetModel.magical.titles.plural}:", relatedObjectIds

    foundRecordsToRelations = (collection) ->
      for relatedObject in collection
        id: relatedObject.id
        title: renderRelationTitle relatedObject
        record: relatedObject

    addPlaceholdersForMissingRecords = (loadedRelations) ->
      loadedIds = (relation.id for relation in loadedRelations)
      loadedRelations.concat(
        for id in relatedObjectIds when not (id in loadedIds)
          {
            id
            title: "« Failed to load related #{relationTargetModel.magical.titles.singular} »"
          }
      )

    placeholdersForRecordInitialState = (
      for id in relatedObjectIds
        {
          id
          title: "« Loading related #{relationTargetModel.magical.titles.singular} »"
        }
    )

    relationTargetModel
      .all(whereIdIn relatedObjectIds)
      .changes
      .map(foundRecordsToRelations)
      .map(addPlaceholdersForMissingRecords)
      .startWith(placeholdersForRecordInitialState)

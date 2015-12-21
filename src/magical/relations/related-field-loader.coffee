debug = require('debug')('ag-magic-model:relations:related-field-loader')

module.exports = relatedFieldLoader = (relationTarget) ->

  { relationTargetModel, renderRelationTitle, relationType } = relationTarget

  one: (relatedObjectId) ->
    debug "Related #{relationTarget.titles.singular}:", relatedObjectId

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
        title: "« Loading related #{relationTarget.titles.singular} »"
      })

  many: (relatedObjectIds) ->
    debug "Related #{relationTarget.titles.plural}:", relatedObjectIds

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
            title: "« Failed to load related #{relationTarget.titles.singular} »"
          }
      )

    placeholdersForRecordInitialState = (
      for id in relatedObjectIds
        {
          id
          title: "« Loading related #{relationTarget.titles.singular} »"
        }
    )

    relationTargetModel
      .all(relationTarget.whereIdInQuery relatedObjectIds)
      .changes
      .doAction((us) ->
        # FIXME: Why does loading users take a lot of time and sometimes never happen?
        debugger if relationType is 'user'
      )
      .map(foundRecordsToRelations)
      .map(addPlaceholdersForMissingRecords)
      .startWith(placeholdersForRecordInitialState)

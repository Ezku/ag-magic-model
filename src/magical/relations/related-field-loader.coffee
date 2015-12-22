debug = require('debug')('ag-magic-model:relations:related-field-loader')

module.exports = relatedFieldLoader = (relationTarget) ->

  { relationTargetModel, renderRelationTitle, relationType } = relationTarget

  LoadingRelatedRecord = (id) ->
    {
      id
      loading: true
      title: "« Loading related #{relationTarget.titles.singular} »"
    }

  MissingRelatedRecord = (id) ->
    {
      id
      failed: true
      title: "« Failed to load related #{relationTarget.titles.singular} »"
    }

  RelatedRecord = (record) ->
    {
      id: record.id
      record
      title: renderRelationTitle record
    }

  one: (relatedObjectId) ->
    debug "Related #{relationTarget.titles.singular}:", relatedObjectId

    return {
      changes: relationTargetModel
        .one(relatedObjectId)
        .changes
        .map(RelatedRecord)
        .startWith(LoadingRelatedRecord(relatedObjectId))
    }

  many: (relatedObjectIds) ->
    debug "Related #{relationTarget.titles.plural}:", relatedObjectIds

    foundRecordsToRelations = (collection) ->
      for relatedObject in collection
        RelatedRecord relatedObject

    addPlaceholdersForMissingRecords = (loadedRelations) ->
      loadedIds = (relation.id for relation in loadedRelations)
      loadedRelations.concat(
        for id in relatedObjectIds when not (id in loadedIds)
          MissingRelatedRecord id
      )

    placeholdersForRecordInitialState = (
      for id in relatedObjectIds
        LoadingRelatedRecord id
    )

    return {
      changes: relationTargetModel
        .all(relationTarget.whereIdInQuery relatedObjectIds)
        .changes
        .map(foundRecordsToRelations)
        .map(addPlaceholdersForMissingRecords)
        .startWith(placeholdersForRecordInitialState)
    }

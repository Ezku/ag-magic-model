deepEquals = require 'deep-equal'
debug = require('debug')('ag-magic-model:relations')

getRelationTarget = require './relations/get-relation-target'

Bacon = require '../external/Bacon'

module.exports = relations = (createMagicModel, ModelClass, modelName, titles, definition) ->

  getRelationTargetByFieldName = getRelationTarget definition, titles, createMagicModel
  modelFieldNamesToRelationTargets = (modelFieldNames) ->
    relationTargets = []

    for modelFieldName in modelFieldNames
      try
        relationTargets.push getRelationTargetByFieldName modelFieldName
      catch e
        debug(
          "Failed to load field '#{modelFieldName}' as a relation for:", modelName
          "Got error:", e
          "Falling through to original model load strategy."
        )

    relationTargets

  return {
    join: (modelFieldNames...) ->
      relationTargets = modelFieldNamesToRelationTargets modelFieldNames

      ###
      KLUDGE: If the provided fields do not have at least one relation, return
      the ModelClass in lieu of a Null Object for this join.
      ###
      return ModelClass unless relationTargets.length

      all: (args...) ->
        changes: joinCollectionFields(
          relationTargets
          ModelClass.all(args...).changes
        )
  }

flatten = (xs) ->
  [].concat.apply([], xs)

indexBy = (field, xs) ->
  result = {}
  for x in xs
    result[x[field]] = x
  result

unique = (xs) ->
  result = []
  for x in xs when not (x in result)
    result.push x
  result

joinCollectionFields = (relationTargets, collectionChangeStream) ->
  relationTargetsByField = indexBy 'relationTargetField', relationTargets

  # (collection) -> Map relationTargetField [ids]
  collectionToJoinFieldIds = (collection) ->
    targetsToIds = {}

    # Take the cartesian product of records and relation targets
    # Map relation targets to record ids by the relation target field
    for relationTargetField, relationTarget of relationTargetsByField
      targetsToIds[relationTargetField] = flatten(
        for record in collection
          switch relationTarget.relationType
            when 'one'
              relatedRecordId = record[relationTargetField]
              if !relatedRecordId
                []
              else
                [relatedRecordId]
            when 'many'
              parseAsArray record[relationTargetField]
            else
              []
      )

    targetsToIds

  # relationTargetFieldsToChangeBatches: (Map relationTargetField Batch([ids], Stream [relatedRecord]))
  scanRelationTargetFieldsAsBatches = do ->
    Batch = (relationTargetField, ids) ->
      relationTarget = relationTargetsByField[relationTargetField]
      records = relatedFieldLoader(relationTarget).many(unique ids)

      {
        ids
        records
      }

    (relationTargetFieldsToChangeBatches, relationTargetFieldsToRecordIds) ->
      for relationTargetField, ids of relationTargetFieldsToRecordIds
        shouldAddBatch = (
          !relationTargetFieldsToChangeBatches[relationTargetField]? or
          !deepEquals(ids, relationTargetFieldsToChangeBatches[relationTargetField].ids)
        )
        if shouldAddBatch
          relationTargetFieldsToChangeBatches[relationTargetField] =
            Batch(relationTargetField, ids)

      relationTargetFieldsToChangeBatches

  # A stream that accumulates the values to be filled in to fields of records
  # in the collection stream.
  # relationIdentityMap: Stream (Map relationTargetField (Map id relatedRecord))
  relationIdentityMap = collectionChangeStream
    .map(collectionToJoinFieldIds)
    .scan({}, scanRelationTargetFieldsAsBatches)
    .flatMapLatest(Bacon.combineTemplate)
    .map (relationTargetFieldsToChangeBatches) ->
      result = {}
      for relationTargetField, batch of relationTargetFieldsToChangeBatches
        result[relationTargetField] = indexBy 'id', batch.records
      result

  # Perform the inverse of collectionToJoinFieldIds – map relation fields to
  # the loaded relation values
  Bacon
    .combineAsArray([collectionChangeStream, relationIdentityMap])
    .map ([collection, relations]) ->
      # Protect records from side-effects by cloning collection before mutation
      for record in collection.clone()
        for relationTargetField, relationTarget of relationTargetsByField
          target = record[relationTargetField]
          switch relationTarget.relationType
            when 'one'
              if target
                record[relationTargetField] = relations[relationTargetField][target]
            when 'many'
              ids = parseAsArray target
              record[relationTargetField] = (
                for id in ids
                  relations[relationTargetField][id]
              )

        record

relatedFieldLoader = ({ relationTargetModel, renderRelationTitle, relationType }) ->

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

parseAsArray = (stringifiedArrayOfIds) ->
  return [] if !stringifiedArrayOfIds
  try
    JSON.parse stringifiedArrayOfIds
  catch error
    []

debug = require('debug')('ag-magic-model:relations')

getRelationTarget = require './relations/get-relation-target'
targetObjectPlaceholder = require './relations/target-object-placeholder'
targetObjectUpdates = require './relations/target-object-updates'

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
      records = relatedFieldLoader(relationTarget).many(ids)

      {
        ids
        records
      }

    (relationTargetFieldsToChangeBatches, relationTargetFieldsToRecordIds) ->
      for relationTargetField, ids of relationTargetFieldsToRecordIds
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
      for record in collection
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
  one: (relatedObjectId) ->
    if false and typeof relatedObjectId isnt 'string'
      # FIXME: There's a state leak that causes already loaded fields to get
      # passed in as "relatedObjectId"
      debugger

    debug "Related #{relationTargetModel.magical.titles.singular}:", relatedObjectId

    targetObjectPlaceholder(relationTargetModel, relatedObjectId)
      .merge(targetObjectUpdates relationTargetModel, relatedObjectId, renderRelationTitle)

  many: (relatedObjectIds) ->
    debug "Related #{relationTargetModel.magical.titles.plural}:", relatedObjectIds

    Bacon.combineAsArray(
      for relatedObjectId in relatedObjectIds || []
        targetObjectPlaceholder(relationTargetModel, relatedObjectId)
          .merge(targetObjectUpdates relationTargetModel, relatedObjectId, renderRelationTitle)
    )

parseAsArray = (stringifiedArrayOfIds) ->
  return [] if !stringifiedArrayOfIds
  try
    JSON.parse stringifiedArrayOfIds
  catch error
    []

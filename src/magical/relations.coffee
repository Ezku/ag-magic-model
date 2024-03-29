deepEquals = require 'deep-equal'
debug = require('debug')('ag-magic-model:relations')

getRelationTarget = require './relations/get-relation-target'
relatedFieldLoader = require './relations/related-field-loader'

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
    related: (modelFieldName) ->
      relationTarget = getRelationTargetByFieldName modelFieldName
      relatedFieldLoader relationTarget

    join: (modelFieldNames...) ->
      relationTargets = modelFieldNamesToRelationTargets modelFieldNames

      ###
      KLUDGE: If the provided fields do not have at least one relation, return
      the ModelClass in lieu of a Null Object for this join.
      ###
      return ModelClass unless relationTargets.length

      all: (args...) ->
        changes: joinFields(relationTargets).inCollectionStream(
          ModelClass.all(args...).changes
        )

      one: (args...) ->
        changes: joinFields(relationTargets).inRecordStream(
          ModelClass.one(args...).changes
        )
  }

joinFields = (relationTargets) ->
  relationTargetsByField = indexBy 'relationTargetField', relationTargets

  loadRelationTargetsInBatches = do ->
    # relationTargetFieldsToChangeBatches: (Map relationTargetField Batch([ids], Stream [relatedRecord]))
    scanRelationTargetFieldsAsBatches = do ->
      Batch = (relationTargetField, ids) ->
        relationTarget = relationTargetsByField[relationTargetField]
        records = relatedFieldLoader(relationTarget).many(unique ids).changes

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

    # loadRelationTargetsInBatches: (
    #   idsByRelationFieldStream: Stream (Map relationTargetField [ids])
    # ) -> Stream (Map relationTargetField (Map id relatedRecord))
    (idsByRelationFieldStream) ->
      # A stream that accumulates the values to be filled in to fields of records
      # in the collection stream.
      relationIdentityMap = idsByRelationFieldStream
        .scan({}, scanRelationTargetFieldsAsBatches)
        .flatMapLatest(Bacon.combineTemplate)
        .map (relationTargetFieldsToChangeBatches) ->
          result = {}
          for relationTargetField, batch of relationTargetFieldsToChangeBatches
            result[relationTargetField] = indexBy 'id', batch.records
          result

  relationLoader = ({ extractTargetIds, mapEachTargetRecord }) -> (changeStream) ->
    idsByRelationFieldStream = changeStream.map (relationSource) ->
      targetsToIds = {}

      # Take the cartesian product of records and relation targets
      # Map relation targets to record ids by the relation target field
      for relationTargetField, relationTarget of relationTargetsByField
        targetsToIds[relationTargetField] = extractTargetIds relationTarget, relationSource

      targetsToIds

    relationIdentityMap = loadRelationTargetsInBatches idsByRelationFieldStream

    # Perform the inverse of groupRelatedIdsByField – map relation fields to
    # the loaded relation values
    Bacon
      .combineAsArray([changeStream, relationIdentityMap])
      .map ([target, relations]) ->
        mapEachTargetRecord target, (record) ->
          for relationTargetField, relationTarget of relationTargetsByField
            relationTarget.assignRelationFields record, relations[relationTargetField]
          record

  return {
    inRecordStream: relationLoader {
      extractTargetIds: (relationTarget, record) ->
        relationTarget.extractTargetIds record

      mapEachTargetRecord: (record, f) ->
        # Protect records from side-effects by cloning before mutation
        f record.clone()
    }

    inCollectionStream: relationLoader {
      extractTargetIds: (relationTarget, collection) ->
        flatten(
          for record in collection
            relationTarget.extractTargetIds record
        )

      mapEachTargetRecord: (collection, f) ->
        # Protect records from side-effects by cloning collection before mutation
        for record in collection.clone()
          f record
    }
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

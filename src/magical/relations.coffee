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

joinCollectionFields = (relationTargets, collectionChangeStream) ->
  collectionChangeStream.flatMapLatest (collection) ->
    collectionRecordPropertyJoinModifications(relationTargets, collection)
      .map ({ collectionIndex, recordProperty, value }) ->
        # WARNING: Mutation here
        collection[collectionIndex][recordProperty] = value
        collection

collectionRecordPropertyJoinModifications = (relationTargets, collection) ->
  ###
  Take the cartesian product of relation targets and collection records, then
  add in whatever required for tracking changes
  ###
  Bacon
    .fromArray(relationTargets)
    .flatMap (relationTarget) ->
      recordProperty = relationTarget.relationTargetField
      relationType = relationTarget.relationType
      forRelatedField = relatedFieldLoader(relationTarget)

      Bacon.fromArray(
        for record, collectionIndex in collection
          {
            collectionIndex
            record
          }
      ).flatMap ({ collectionIndex, record }) ->
        changes = switch relationType
          when 'one'
            relatedRecordId = record[recordProperty]
            if !relatedRecordId
              Bacon.never()
            else
              forRelatedField.one(relatedRecordId)
          when 'many'
            relatedRecordIds = parseAsArray record[recordProperty]
            forRelatedField.many(relatedRecordIds)
          else
            throw new Error "Unsupported relation type: #{relationType}"

        changes.map (value) ->
          {
            collectionIndex
            recordProperty
            value
          }

relatedFieldLoader = ({ relationTargetModel, renderRelationTitle, relationType }) ->
  one: (relatedObjectId) ->
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

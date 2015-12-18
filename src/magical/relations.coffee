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
        changes:
          ModelClass
            .all(args...)
            .changes
            .flatMapLatest(joinCollectionFields relationTargets)
  }

# TODO: Handle multiple relation targets
joinCollectionFields = ([relationTarget]) ->
  switch relationTarget.relationType
    when 'one'
      joinOneToCollectionRecords relationTarget
    when 'many'
      joinManyToCollectionRecords relationTarget
    else
      throw new Error "Unsupported relation type: #{relationTarget.relationType}"

joinOneToCollectionRecords = (relationTarget) ->
  modelFieldName = relationTarget.relationTargetField

  (collection) ->
    forRelatedField = relatedFieldLoader(relationTarget)

    Bacon.combineAsArray(
      for record in collection then do (record) ->
        relatedRecordId = record[modelFieldName]

        if !relatedRecordId
          Bacon.once record
        else
          forRelatedField
            .one(relatedRecordId)
            .changes
            .map (relatedRecord) ->
              # WARNING: Mutation here
              record[modelFieldName] = relatedRecord
              record
    )

joinManyToCollectionRecords = (relationTarget) ->
  modelFieldName = relationTarget.relationTargetField

  (collection) ->
    forRelatedField = relatedFieldLoader(relationTarget)

    Bacon.combineAsArray(
      for record in collection then do (record) ->
        relatedRecordIds = parseAsArray record[modelFieldName]

        forRelatedField
          .many(relatedRecordIds)
          .changes
          .map (relatedRecords) ->
            # WARNING: Mutation here
            record[modelFieldName] = relatedRecords
            record
    )

relatedFieldLoader = ({ relationTargetModel, renderRelationTitle, relationType }) ->
  one: (relatedObjectId) ->
    debug "Related #{relationTargetModel.magical.titles.singular}:", relatedObjectId

    changes = targetObjectPlaceholder(relationTargetModel, relatedObjectId)
      .merge(targetObjectUpdates relationTargetModel, relatedObjectId, renderRelationTitle)

    { changes }

  many: (relatedObjectIds) ->
    debug "Related #{relationTargetModel.magical.titles.plural}:", relatedObjectIds

    changes = Bacon.combineAsArray(
      for relatedObjectId in relatedObjectIds || []
        targetObjectPlaceholder(relationTargetModel, relatedObjectId)
          .merge(targetObjectUpdates relationTargetModel, relatedObjectId, renderRelationTitle)
    )

    { changes }

parseAsArray = (stringifiedArrayOfIds) ->
  return [] if !stringifiedArrayOfIds
  try
    JSON.parse stringifiedArrayOfIds
  catch error
    []

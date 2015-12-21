
module.exports = (definition, titles, createMagicModel) ->

  getRelationTargetModel = (relationType, modelFieldName, relationFieldSchema) ->
    if relationType is 'user'
      return supersonic.auth.users

    if !relationFieldSchema.metadata?.collection?
      throw new Error "Field #{modelFieldName} does not appear to be a relation: missing target collection"

    relationTargetModel = createMagicModel relationFieldSchema.metadata.collection

  getRelationTitleRenderer = (relationType, relationFieldSchema, relationTargetModel) ->
    if relationType is 'user'
      return (user) ->
        user.metadata?.name ? user.username

    ###
    Collection field represents the requested title field when rendering this relation.

    If it's unconfigured, it gets set to the target model's title field.
    ###
    collectionFieldName = relationFieldSchema.metadata.collection_field ? relationTargetModel.magical.definition.titleField

    ###
    KLUDGE: If the provided collection field is obviously a relation, fall back to
    the record's default title.
    FIXME: The title may also require resolving relations, making this recursive.
    ###
    renderRelationTitle = switch
      when relationTargetModel.magical.definition.schema.fields[collectionFieldName].display_type is 'multirelation'
        relationTargetModel.magical.titles.record
      when relationTargetModel.magical.definition.schema.fields[collectionFieldName].display_type is 'relation'
        relationTargetModel.magical.titles.record
      else
        titleField = collectionFieldName
        formatTitle = relationTargetModel.magical.formatter[titleField]
        (record) ->
          formatTitle(record[titleField])

  getRelationTarget = (modelFieldName) ->
    relationFieldSchema = definition.schema.fields[modelFieldName]

    if !relationFieldSchema
      throw new Error "No such field on #{titles.singular}: #{modelFieldName}"

    relationType = switch relationFieldSchema.display_type
      when 'multirelation'
        'many'
      when 'relation'
        'one'
      when 'user'
        'user'
      else
        throw new Error "Field #{modelFieldName} does not appear to be a relation: expected relation type, got '#{relationFieldSchema.display_type}'"

    relationTargetModel = getRelationTargetModel relationType, modelFieldName, relationFieldSchema
    renderRelationTitle = getRelationTitleRenderer relationType, relationFieldSchema, relationTargetModel

    RelationTarget.of {
      relationTargetField: modelFieldName
      relationTargetModel
      renderRelationTitle
      relationType
    }

class RelationTarget
  constructor: ({
    @relationTargetField
    @relationTargetModel
    @renderRelationTitle
    @relationType
  }) ->
    @titles ?= @relationTargetModel.magical.titles

  @of: (params = {}) ->
    switch params.relationType
      when 'one'
        new SingleRelationTarget params
      when 'many'
        new MultiRelationTarget params
      when 'user'
        new UserRelationTarget params
      else
        new RelationTarget params

  extractTargetIds: -> []
  assignRelationFields: ->
  whereIdInQuery: (ids) ->
    # FIXME: Why '_id'? Does this hold for all resource types, all sources?
    query: JSON.stringify
      _id:
        $in: ids

class SingleRelationTarget extends RelationTarget
  extractTargetIds: (record) ->
    relatedRecordId = record[@relationTargetField]
    if !relatedRecordId
      []
    else
      [relatedRecordId]

  assignRelationFields: (record, relatedRecordsById) ->
    recordId = record[@relationTargetField]
    if recordId
      record[@relationTargetField] = relatedRecordsById[recordId]

class MultiRelationTarget extends RelationTarget
  extractTargetIds: (record) ->
    parseAsArray record[@relationTargetField]

  assignRelationFields: (record, relatedRecordsById) ->
    recordIds = parseAsArray record[@relationTargetField]
    record[@relationTargetField] = (
      for recordId in recordIds
        relatedRecordsById[recordId]
    )

class UserRelationTarget extends SingleRelationTarget
  titles:
    singular: 'user'
    plural: 'users'

  whereIdInQuery: (ids) ->
    # FIXME: API does not appear to support querying by id
    query: JSON.stringify {}

parseAsArray = (stringifiedArrayOfIds) ->
  return [] if !stringifiedArrayOfIds
  try
    JSON.parse stringifiedArrayOfIds
  catch error
    []


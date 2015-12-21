
module.exports = (definition, titles, createMagicModel) ->

  getRelationTargetModel = (modelFieldName, relationFieldSchema) ->
    if !relationFieldSchema.metadata?.collection?
      throw new Error "Field #{modelFieldName} does not appear to be a relation: missing target collection"

    relationTargetModel = createMagicModel relationFieldSchema.metadata.collection

  getRelationTitleRenderer = (relationFieldSchema, relationTargetModel) ->
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
      else
        throw new Error "Field #{modelFieldName} does not appear to be a relation: expected relation type, got '#{relationFieldSchema.display_type}'"

    relationTargetModel = getRelationTargetModel modelFieldName, relationFieldSchema
    renderRelationTitle = getRelationTitleRenderer relationFieldSchema, relationTargetModel

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

  @of: (params = {}) ->
    switch params.relationType
      when 'one'
        new SingleRelationTarget params
      when 'many'
        new MultiRelationTarget params
      else
        new RelationTarget params

  extractTargetIds: -> []
  assignRelationFields: ->

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

parseAsArray = (stringifiedArrayOfIds) ->
  return [] if !stringifiedArrayOfIds
  try
    JSON.parse stringifiedArrayOfIds
  catch error
    []


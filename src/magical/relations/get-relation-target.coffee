
module.exports = getRelationTarget = (definition, titles, createMagicModel) -> (modelFieldName) ->
  relationFieldSchema = definition.schema.fields[modelFieldName]

  if !relationFieldSchema
    throw new Error "No such field on #{titles.singular}: #{modelFieldName}"

  if !relationFieldSchema.metadata?.collection?
    throw new Error "Field #{modelFieldName} does not appear to be a relation: missing target collection"

  relationType = switch relationFieldSchema.display_type
    when 'multirelation'
      'many'
    when 'relation'
      'one'
    else
      throw new Error "Field #{modelFieldName} does not appear to be a relation: expected relation type, got '#{relationFieldSchema.display_type}'"

  ###
  Collection field represents the requested title field when rendering this relation.

  If it's unconfigured, it gets set to the target model's title field.
  ###
  relationTargetModel = createMagicModel relationFieldSchema.metadata.collection
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

  {
    relationTargetField: modelFieldName
    relationTargetModel
    renderRelationTitle
    relationType
  }

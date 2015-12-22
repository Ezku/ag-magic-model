moment = require 'moment/min/moment.min.js'

nullable = (formatField) -> (value) ->
  if !value?
    return ''
  else
    formatField value

module.exports = formats = (createMagicModel) ->
  date: (fieldSchema) ->
    format = fieldSchema?.metadata?.format ? "YYYY-MM-DD"

    nullable (date) ->
      moment(date).format(format)

  file: (fieldSchema) -> nullable (file) ->
    file.meta?.name ? file.key

  relation: (fieldSchema) ->
    if !fieldSchema.metadata?.collection?
      return (anything) ->
        "« #{fieldSchema.label} has no target collection »"

    relationTargetModel = createMagicModel fieldSchema.metadata.collection

    (relation) ->
      ###
      If the relation has been joined, we can use the formatted title provided by
      the join. If not, we can only declare it is present / not present.
      ###
      switch
        when !relation?
          "« missing #{relationTargetModel.magical.titles.singular} »"
        when relation.title?
          relation.title
        else
          "« One #{relationTargetModel.magical.titles.singular} record »"

  multirelation: (fieldSchema) ->
    if !fieldSchema.metadata?.collection?
      return (anything) ->
        "« #{fieldSchema.label} has no target collection »"

    relationTargetModel = createMagicModel fieldSchema.metadata.collection

    (multirelation) ->
      ###
      If the relation has been joined, we can use the formatted title provided by
      the join. If not, we can only declare it is present / not present.
      ###
      switch
        when !multirelation?
          "« missing #{relationTargetModel.magical.titles.plural} »"
        when multirelation instanceof Array
          switch
            when multirelation.length is 0
              "« No #{relationTargetModel.magical.titles.plural} »"
            else
              (relation.title for relation in multirelation).join ', '
        else
          count = relationsToArray(multirelation).length
          switch
            when count is 0
              "« No #{relationTargetModel.magical.titles.plural} »"
            when count is 1
              "« One #{relationTargetModel.magical.titles.singular} »"
            else
              "« #{count} #{relationTargetModel.magical.titles.plural} »"

  user: (fieldSchema) ->
    (user) ->
      switch
        when !user
          "« missing user »"
        when user.id? and user.title?
          user.title
        else
          user.metadata?.name ? user.username

relationsToArray = (input) ->
  switch
    when typeof input is 'string'
      try
        JSON.parse input
      catch e
        []
    else
      input || []

moment = require 'moment/min/moment.min.js'
magical = require '../index.coffee'

nullable = (formatField) -> (value) ->
  if !value?
    return ''
  else
    formatField value

module.exports = formats =
  date: (fieldSchema) ->
    format = fieldSchema?.metadata?.format ? "YYYY-MM-DD"

    nullable (date) ->
      moment(date).format(format)

  file: (fieldSchema) -> nullable (file) ->
    file.meta?.name ? file.key

  relation: (fieldSchema) ->
    relationTargetModel = magical fieldSchema.metadata.collection

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
    relationTargetModel = magical fieldSchema.metadata.collection

    (multirelation) ->
      ###
      If the relation has been joined, we can use the formatted title provided by
      the join. If not, we can only declare it is present / not present.
      ###
      switch
        when !multirelation?
          "« missing #{relationTargetModel.magical.titles.plural} »"
        when multirelation instanceof Array
          (relation.title for relation in multirelation).join ', '
        else
          count = relationsToArray(multirelation).length
          switch count
            when 0
              "« No #{relationTargetModel.magical.titles.plural} »"
            when 1
              "« One #{relationTargetModel.magical.titles.singular} »"
            else
              "« #{count} #{relationTargetModel.magical.titles.plural} »"

relationsToArray = (input) ->
  switch
    when typeof input is 'string'
      try
        JSON.parse input
      catch e
        []
    else
      input || []

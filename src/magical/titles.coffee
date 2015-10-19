module.exports = (definition, formatters) ->

  singular: definition?.title?.singular || ''
  plural: definition?.title?.plural || ''

  record: (record) ->
    titleField = definition.titleField

    if !titleField?
      return "« missing title »"

    titleValue = record[titleField]

    if !titleValue?
      return "« missing '#{titleField}' »"

    formatters[titleField](titleValue)

module.exports = (definition, formatters, record) ->
  titleField = definition.titleField

  if !titleField?
    return "« missing title »"

  titleValue = record[titleField]

  if !titleValue?
    return "« missing '#{titleField}' »"

  formatters[titleField](titleValue)

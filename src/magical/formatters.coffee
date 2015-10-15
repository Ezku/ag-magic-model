formats = require './formats'

id = (v) -> v

module.exports = (schemaFields) ->
  formatters = {}

  for fieldName, fieldSchema of schemaFields

    displayType = fieldSchema?.display_type ? 'string'
    formatField = formats[displayType]?(fieldSchema) ? id

    do (fieldName, formatField) ->
      formatters[fieldName] = (value) ->
        if !value?
          return ''
        else
          formatField value

  formatters

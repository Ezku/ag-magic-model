createFormats = require './formats'

id = (v) -> v

module.exports = (createMagicModel, schemaFields) ->
  formats = createFormats(createMagicModel)

  formatters = {}

  for fieldName, fieldSchema of schemaFields

    displayType = fieldSchema?.display_type ? 'string'
    formatField = formats[displayType]?(fieldSchema) ? id

    formatters[fieldName] = formatField

  formatters

module.exports = (formatters, record) ->
  props = {}

  for fieldName, formatField of (formatters || {})
    do (fieldName, formatField) ->
      props[fieldName] =
        enumerable: true
        get: ->
          formatField record[fieldName]

  Object.defineProperties {}, props

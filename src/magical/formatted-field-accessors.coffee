moment = require 'moment/min/moment.min.js'

formats =
  date: (fieldSchema) ->
    format = fieldSchema?.metadata ? "YYYY-MM-DD"

    (value) ->
      moment(value).format(format)

id = (v) -> v

module.exports = (schema, record) ->
  props = {}

  for fieldName, fieldSchema of (schema || {})
    displayType = fieldSchema?.display_type ? 'string'
    format = formats[displayType]?(fieldSchema) ? id

    do (format, fieldName) ->
      props[fieldName] =
        enumerable: true
        get: ->
          if !value?
            return ''
          else
            format record[fieldName]

  Object.defineProperties {}, props

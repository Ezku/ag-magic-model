moment = require 'moment/min/moment.min.js'

module.exports = formats =
  date: (fieldSchema) ->
    format = fieldSchema?.metadata ? "YYYY-MM-DD"

    (value) ->
      moment(value).format(format)

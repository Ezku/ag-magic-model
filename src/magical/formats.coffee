moment = require 'moment/min/moment.min.js'

module.exports = formats =
  date: (fieldSchema) ->
    format = fieldSchema?.metadata ? "YYYY-MM-DD"

    (date) ->
      moment(date).format(format)

  file: (fieldSchema) -> (file) ->
    file.meta?.name ? file.key

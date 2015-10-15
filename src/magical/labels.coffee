module.exports = (ModelClass, schema) ->
  labels = {}

  for fieldName, fieldSchema of (schema.fields || {})
    labels[fieldName] = switch
      when fieldSchema?.label?
        fieldSchema.label
      else
        "« missing #{fieldName} »"

  labels


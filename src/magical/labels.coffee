module.exports = (ModelClass, schemaFields) ->
  labels = {}

  for fieldName, fieldSchema of schemaFields
    labels[fieldName] = switch
      when fieldSchema?.label?
        fieldSchema.label
      else
        "« missing #{fieldName} »"

  labels


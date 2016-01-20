ROUTE_TO_RECORD_DETAILS = "com.appgyver.dataentrydetails"

module.exports = routeAccessors = (modelName, routes) ->
  ###
  The target route might not exist even if the resource does exist.
  In this case default to the standalone record details view.
  ###
  'new': do ->
    route = routes["data.#{modelName}.new"]?.uid ? ROUTE_TO_RECORD_DETAILS
    addRecordTypeParam route, modelName

  'show': do ->
    route = routes["data.#{modelName}.show"]?.uid ? ROUTE_TO_RECORD_DETAILS
    addRecordTypeParam route, modelName

addRecordTypeParam = (route, modelName) ->
  "#{route}?record-type=#{modelName}"

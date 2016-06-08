###
Conference.coffee

@description :: TODO: You might write a short summary of how this model works and what it represents here.
@docs        :: http://sailsjs.org/#!documentation/models
###

require 'date-utils'

module.exports =
  attributes:
    startDate:
      type: 'string'
      required: true
    endDate:
      type: 'string'
    name:
      type: 'string'
      required: true

  beforeCreate: (values, callback) ->
    date = (new Date(values.startDate))
    if date.toString() == 'Invalid Date'
      callback({error: 'Invalid Date'})
    else
      values.key = date.toFormat('YYMMDDHH24MI')
      callback()

###
Conference.coffee

@description :: TODO: You might write a short summary of how this model works and what it represents here.
@docs        :: http://sailsjs.org/#!documentation/models
###

require 'date-utils'

module.exports =
  attributes:
    date:
      type: 'datetime'
      required: true
    startTime:
      type: 'integer'
    endTime:
      type: 'integer'
    name:
      type: 'string'
      required: true
    status:
      type: 'string'
      defaultsTo: ''

  beforeCreate: (values, callback) ->
    date = (new Date(values.date))
    if date.toString() == 'Invalid Date'
      callback({error: 'Invalid Date'})
    else
      values.key = date.toFormat('YYMMDDHH24MI')
      callback()

 start: ->


###
Conference.coffee

@description :: TODO: You might write a short summary of how this model works and what it represents here.
@docs        :: http://sailsjs.org/#!documentation/models
###

require 'date-utils'

Status =
  notOpened: 0
  opening: 1
  closed: 2

module.exports =

  attributes:
    date:
      type: 'datetime'
      required: true
    startedAt:
      type: 'datetime'
    stoppedAt:
      type: 'datetime'
    name:
      type: 'string'
      required: true
    status:
      type: 'integer'
      defaultsTo: Status.notOpened

    # Relation
    attendances:
      collection: 'attendance'
      via: 'conference'
    likes:
      collection: 'like'
      via: 'conference'
    resetTimes:
      collection: 'resetTime'
      via: 'conference'

    # Methods
    start: (callback) ->
      @startedAt = new Date()
      @stoppedAt = null
      @status = Status.opening
      @save callback

    stop: (callback) ->
      @stoppedAt = new Date()
      @status = Status.closed
      @save callback

    isOpening: ->
      @status == Status.opening

  beforeCreate: (values, callback) ->
    date = (new Date(values.date))
    if date.toString() == 'Invalid Date'
      callback({error: 'Invalid Date'})
    else
      values.key = date.toFormat('YYMMDDHH24MI')
      callback()



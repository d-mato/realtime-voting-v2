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
    manualMode:
      type: 'boolean'
      defaultsTo: false
    timer:
      type: 'integer'
      defaultsTo: 60

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

    get_last_reset: ->
      if @manualMode
        last_reset = if @resetTimes.length == 0 then @startedAt else _.last(@resetTimes).time
      else
        last_time = if @stoppedAt then @stoppedAt else new Date()
        elapsed = last_time - @startedAt
        last_reset = last_time - elapsed % (@timer*1000)
      return last_reset

    clean: ->
      # 継続的に閲覧している参加者をフィルタ => 全ての参加者
      @attendances = @attendances.filter (attendance) =>
        attendance.createdAt.toString() != attendance.updatedAt.toString() && attendance.updatedAt > @startedAt
      # 更に最終更新が10秒以内でフィルタ => 現在の参加者
      @currentAttendances = @attendances.filter (attendance) =>
        new Date() - attendance.updatedAt < 10*1000

      # カンファレンス開始前のlikeを除去
      @likes = @likes.filter (like) => @startedAt < like.createdAt

    runCounter: ->
      last_reset = @get_last_reset()
      @attendancesCount = @attendances.length
      @likesCount = @likes.length
      @lastAttendancesCount = @attendances.filter( (attendance) -> attendance.updatedAt > last_reset).length
      @lastLikesCount = @likes.filter( (like) -> like.createdAt > last_reset).length

    buildTables: ->
      elapsed = if @stoppedAt # milliseconds
        @stoppedAt - @startedAt
      else new Date() - @startedAt

      timeTable = [0..parseInt(elapsed / (@timer*1000))].map -> 0
      resetTable = [0..(@resetTimes.length)].map -> 0
      officeTable = {}

      @likes.forEach (like) =>
        s = parseInt((like.createdAt - @startedAt)/1000) # 開始後何秒後にいいねされたか
        timeTable[parseInt(s/@timer)] += 1

        officeTable[like.office] ||= 0
        officeTable[like.office] += 1

        pos = 0
        @resetTimes.forEach (resetTime, i) ->
          if resetTime.time < like.createdAt
            pos = i+1
        resetTable[pos] += 1

      _.assign @, {timeTable, resetTable, officeTable}

    timerCounter: ->
      return 0 if @stoppedAt || @manualMode
      elapsed = new Date() - @startedAt
      return @timer - parseInt((elapsed % (@timer*1000))/1000)

  beforeCreate: (values, callback) ->
    date = (new Date(values.date))
    if date.toString() == 'Invalid Date'
      callback({error: 'Invalid Date'})
    else
      values.key = date.toFormat('YYMMDDHH24MI')
      callback()



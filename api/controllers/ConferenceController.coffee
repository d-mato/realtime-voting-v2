###
ConferenceController

@description :: Server-side logic for managing conferences
@help        :: See http://links.sailsjs.org/docs/controllers
###
# require 'underscore'
room_name = (id) -> "conference##{id}"

module.exports =

  index: (req, res) ->
    Conference.find().exec (err, items) ->
      res.view {conferences: items}

  show: (req, res) ->
    Conference.findOne(req.params.id).populate('attendances').populate('likes').populate('resetTimes').exec (err, conference) ->
      return res.notFound() unless conference

      # 継続的に閲覧している参加者をフィルタ => 全ての参加者
      conference.allAttendances = conference.attendances.filter (attendance) ->
        attendance.createdAt.toString() != attendance.updatedAt.toString() && attendance.updatedAt > conference.startedAt
      # 更に最終更新が10秒以内でフィルタ => 現在の参加者
      conference.currentAttendances = conference.allAttendances.filter (attendance) ->
        new Date() - attendance.updatedAt < 10*1000

      # カンファレンス開始前のlikeを除去
      conference.likes = conference.likes.filter (like) -> conference.startedAt < like.createdAt

      # 手動リセットモードのlast
      last = if conference.resetTimes.length == 0 then conference.startedAt else _.last(conference.resetTimes).time

      conference.lastAttendances = conference.allAttendances.filter( (attendance) -> attendance.updatedAt > last).length
      conference.lastLikes = conference.likes.filter( (like) -> like.createdAt > last).length

      res.view {conference, layout: 'layout_admin'}
      console.log conference

  create: (req, res) ->
    params =
      date: req.body.date
      name: req.body.name
    Conference.create(params).exec (err, created) ->
      if err
        console.log err
        res.negotiate(err)
      else
        console.log 'Created!\n', created
        res.redirect '/admin/conferences'

  # Ajax API
  destroy: (req, res) ->
    Conference.destroy(req.params.id).exec (err) ->
      if err
        console.log err
        res.badRequest()
      else
        console.log 'Destroyed!\n'
        res.ok()

  start: (req, res) ->
    Conference.findOne(req.params.id).exec (err, item) ->
      if err
        console.log err
        res.badRequest()
      else
        item.start (err) ->
          return res.badRequest() if err
          console.log 'Started!', item.key
          sails.sockets.broadcast room_name(req.params.id), 'conference-started', {} # Broadcast
          res.ok(item.toJSON())


  stop: (req, res) ->
    Conference.findOne(req.params.id).exec (err, item) ->
      if err
        console.log err
        res.badRequest()
      else
        item.stop (err) ->
          return res.badRequest() if err
          console.log 'Stopped!', item.key
          sails.sockets.broadcast room_name(req.params.id), 'conference-stopped', {} # Broadcast
          res.ok(item.toJSON())

  reset: (req, res) ->
    Conference.findOne(req.params.id).exec (err, conference) ->
      if err
        console.log err
        res.badRequest()
      else
        sails.sockets.broadcast room_name(conference.id), 'reset', {} # Broadcast
        res.ok(conference.toJSON())
        ResetTime.create({time: new Date(), conference: conference}).exec (err, created) ->
          if err
            console.log err
          else
            console.log 'Created!\n', created

  statistics: (req, res) ->
    Conference.findOne(req.params.id).populate('attendances').populate('likes').populate('resetTimes').exec (err, conference) ->
      return res.notFound() unless conference

      likes = conference.likes.filter (like) -> conference.startedAt < like.createdAt

      Timer = 60 # seconds
      elapsed = if conference.stoppedAt # milliseconds
        conference.stoppedAt - conference.startedAt
      else new Date() - conference.startedAt

      timeTable = [0..parseInt(elapsed / (Timer*1000))].map -> 0
      resetTable = [0..(conference.resetTimes.length)].map -> 0
      officeTable = {}

      likes.forEach (like) ->
        s = parseInt((like.createdAt - conference.startedAt)/1000) # 開始後何秒後にいいねされたか
        timeTable[parseInt(s/Timer)] += 1

        officeTable[like.office] ||= 0
        officeTable[like.office] += 1

        pos = 0
        conference.resetTimes.forEach (resetTime, i) ->
          if resetTime.time < like.createdAt
            pos = i+1
        resetTable[pos] += 1

      res.json {likes: likes, officeTable, timeTable, resetTable}

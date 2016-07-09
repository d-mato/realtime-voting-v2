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
    if req.xhr
      Conference.findOne(req.params.id).populate('attendances').populate('likes').populate('resetTimes').exec (err, conference) ->
        return res.notFound() unless conference

        conference.clean()
        conference.runCounter()
        res.json conference.toJSON()

    else
      Conference.findOne(req.params.id).exec (err, conference) ->
        return res.notFound() unless conference
        res.view {conference, layout: 'layout_admin'}

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

      conference.clean()
      conference.runCounter()
      conference.buildTables()

      data = {}
      data.timerCounter = conference.timerCounter()
      ['officeTable', 'timeTable', 'resetTable', 'lastAttendancesCount', 'lastLikesCount', 'attendancesCount', 'likesCount'].forEach (key) ->
        data[key] = conference[key]
      res.json data


###
ConferenceController

@description :: Server-side logic for managing conferences
@help        :: See http://links.sailsjs.org/docs/controllers
###

room_name = (id) -> "conference##{id}"

module.exports =

  index: (req, res) ->
    Conference.find().exec (err, items) ->
      res.view {conferences: items}

  show: (req, res) ->
    Conference.findOne(req.params.id).populate('attendances').populate('likes').exec (err, item) ->
      return res.notFound() unless item

      item.all_attendances = item.attendances.filter (attendance) ->
        # 継続的に閲覧している参加者をフィルタ => 全ての参加者
        attendance.createdAt.toString() != attendance.updatedAt.toString()
      item.current_attendances = item.all_attendances.filter (attendance) ->
        # 更に最終更新が10秒以内でフィルタ => 現在の参加者
        (new Date()).getTime() - attendance.updatedAt.getTime() < 10*1000

      res.view {conference: item, layout: 'layout_admin'}
      console.log item

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
    Conference.findOne(req.params.id).exec (err, item) ->
      if err
        console.log err
        res.badRequest()
      else
        sails.sockets.broadcast room_name(req.params.id), 'reset', {} # Broadcast
        res.ok(item.toJSON())

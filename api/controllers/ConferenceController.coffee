###
ConferenceController

@description :: Server-side logic for managing conferences
@help        :: See http://links.sailsjs.org/docs/controllers
###

SendStatusInterval = null

module.exports =

  index: (req, res) ->
    Conference.find().exec (err, items) ->
      res.view {conferences: items}

  show: (req, res) ->
    Conference.findOne(req.params.id).populate('attendances').populate('likes').exec (err, item) ->
      return res.notFound() unless item
      item.attendances = item.attendances.filter (attendance) -> attendance.createdAt.toString() != attendance.updatedAt.toString()
      res.view {conference: item}
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
          sails.sockets.blast 'conference-started', item.toJSON() # Broadcast
          res.ok(item.toJSON())
          # clearInterval SendStatusInterval if SendStatusInterval
          # SendStatusInterval = setInterval ->
          #   sails.sockets.blast 'conference-opened', {status: 'opened'}
          #   console.log 'interval'
          # , 1000


  stop: (req, res) ->
    Conference.findOne(req.params.id).exec (err, item) ->
      if err
        console.log err
        res.badRequest()
      else
        item.stop (err) ->
          return res.badRequest() if err
          console.log 'Stopped!', item.key
          sails.sockets.blast 'conference-stopped', item.toJSON() # Broadcast
          res.ok(item.toJSON())
          # clearInterval SendStatusInterval if SendStatusInterval

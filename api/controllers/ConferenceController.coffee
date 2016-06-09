###
ConferenceController

@description :: Server-side logic for managing conferences
@help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports =

  index: (req, res) ->
    Conference.find().exec (err, items) ->
      res.view {conferences: items}

  show: (req, res) ->
    Conference.findOne(req.params.id).exec (err, item) ->
      return res.notFound() unless item
      res.view {conference: item}

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
        console.log 'Started!', item.key
        sails.sockets.blast 'conference-started', item.toJSON() # Broadcast
        item.start (err) ->
          return res.badRequest() if err
          res.ok(item.toJSON())

  stop: (req, res) ->
    Conference.findOne(req.params.id).exec (err, item) ->
      if err
        console.log err
        res.badRequest()
      else
        console.log 'Stopped!', item.key
        sails.sockets.blast 'conference-stopped', item.toJSON() # Broadcast
        item.stop (err) ->
          return res.badRequest() if err
          res.ok(item.toJSON())


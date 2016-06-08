###
RedirectController

@description :: Server-side logic for managing redirects
@help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports =

  index: (req, res) ->
    Redirect.find().exec (err, items) ->
      res.view {redirects: items}

  create: (req, res) ->
    params =
      url: req.body.url
      key: req.body.key
    Redirect.create(params).exec (err, created) ->
      if err
        console.log err
        res.negotiate(err)
      else
        console.log 'Created!\n', created
        res.redirect '/admin/redirects'

  # Ajax API
  destroy: (req, res) ->
    Redirect.destroy(req.params.id).exec (err) ->
      if err
        console.log err
        res.badRequest()
      else
        console.log 'Destroyed!\n'
        res.ok()

  redirect: (req, res) ->
    Redirect.findOne({key: req.params.key}).exec (err, item) ->
      if item
        res.redirect item.url
      else
        res.redirect '/'


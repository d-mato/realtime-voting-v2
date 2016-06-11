###
LikeController

@description :: Server-side logic for managing likes
@help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports = {

  create: (req, res) ->
    params =
      key: req.body.key
      office: req.body.office
      ip_addr: req.ip
    Like.create(params).exec (err, item) ->
      return res.badRequest()if err or !item
      res.send item.toJSON()

}


###
AttendanceController

@description :: Server-side logic for managing attendances
@help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports = {

  create: (req, res) ->
    Conference.findOne({key: req.body.key}).exec (err, conference) ->
      return res.badRequest({error: 'Invalid conference key'}) if err or !conference
      return res.badRequest({error: 'Invalid conference status'}) unless conference.isOpening()

      sails.sockets.join(req.socket, 'conference#'+conference.id)

      params =
        conference: conference.id
        office: req.body.office
        ip_addr: req.ip
        session_id: req.sessionID
      Attendance.findOrCreate(params).exec (err, item) ->
        return res.badRequest() if err or !item
        if item.createdAt == item.updatedAt
          res.send item.toJSON()
        else
          Attendance.update(params, {updatedAt: new Date()}).exec (err, items) ->
            item = items[0]
            res.send item.toJSON()

}


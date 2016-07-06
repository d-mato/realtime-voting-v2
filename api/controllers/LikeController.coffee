###
LikeController

@description :: Server-side logic for managing likes
@help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports = {

  create: (req, res) ->
    Conference.findOne({key: req.body.key}).exec (err, conference) ->
      return res.badRequest({error: 'Invalid conference key'}) if err or !conference
      return res.badRequest({error: 'Invalid conference status'}) unless conference.isOpening()

      Attendance.findOne({conference_id: conference.id, session_id: req.sessionID}).exec (err, attendance) ->
        return res.badRequest({error: 'Invalid client'}) if err or !attendance
        params =
          conference_id: conference.id
          attendance_id: attendance.id
        Like.create(params).exec (err, item) ->
          return res.badRequest()if err or !item
          res.send item.toJSON()

}


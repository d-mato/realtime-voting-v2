###
Like.coffee

@description :: TODO: You might write a short summary of how this model works and what it represents here.
@docs        :: http://sailsjs.org/#!documentation/models
###

module.exports =

  attributes: {}
  beforeCreate: (values, callback) ->
    Conference.findOne({key: values.key}).exec (err, conference) ->
      return callback({error: 'Invalid conference key'}) if err or !conference
      return callback({error: 'Invalid conference status'}) unless conference.isOpening()

      values.conference_id = conference.id
      callback()




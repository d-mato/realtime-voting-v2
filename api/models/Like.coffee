###
Like.coffee

@description :: TODO: You might write a short summary of how this model works and what it represents here.
@docs        :: http://sailsjs.org/#!documentation/models
###

module.exports =

  attributes: {}
  beforeCreate: (values, callback) ->
    Conference.findOne({key: values.key}).exec (err, item) ->
      return callback({error: 'Invalid conference key'}) if err or !item

      values.conference_id = item.id
      callback()




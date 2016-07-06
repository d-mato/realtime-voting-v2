###
Attendance.coffee

@description :: TODO: You might write a short summary of how this model works and what it represents here.
@docs        :: http://sailsjs.org/#!documentation/models
###

module.exports =

  autoUpdatedAt: true
  attributes:
    # Relation
    conference:
      model: 'conference'
    likes:
      collection: 'like'
      via: 'attendance'


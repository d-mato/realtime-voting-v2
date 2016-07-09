app.Timer = 60

class Conference extends Backbone.Model
  url: -> "/admin/conferences/#{@id}"
  defaults:
    timer: 60
  start: ->
    $.ajax({url: @url()+'/start'}).done (conference) ->
      $('.status span').text(conference.status)
  stop: ->
    $.ajax({url: @url()+'/stop'}).done (conference) ->
      $('.status span').text(conference.status)
  reset: ->
    $.ajax({url: location.href+'/reset'})

class ConferenceStatistics extends Backbone.Model
  url: -> "/admin/conferences/#{@id}/statistics"
  initialize: ->
    @on 'change:lastLikesCount change:lastAttendancesCount', (model, changed) ->
      percentage = if @get('lastAttendancesCount') then 100*@get('lastLikesCount')/@get('lastAttendancesCount') else 0
      @set '_lastLikesPercentage', Math.min percentage, 100

id = location.href.match(/conferences\/(\d+)/)[1]

conference = new Conference({id})
statistics = new ConferenceStatistics({id})

conference.fetch().done ->
  app.Timer = conference.get 'timer'
  app.ManualMode = conference.get 'manualMode'

  new app.Views.PieChartView(model: statistics)
  new app.Views.TimeChartView(model: statistics)
  new app.Views.OfficeChartView(model: statistics)

statistics.fetch()
setInterval ->
  statistics.fetch()
, 1000

class Timer extends Backbone.View
  el: '.timer'
  initialize: ->
    # @countdown = setInterval ->
    #   t = parseInt $('.timer').text()
    #   $('.timer').text((app.Timer+t-1)%app.Timer)
    # , 1000
    statistics.on 'change:timerCounter', (model, changed) ->
      $('.timer').text(changed)
    # conference.on 'change:status', (model, changed) ->
    #   clearInterval(@countdown) if changed == 2

new Timer()

$('.start').on 'click', -> conference.start()

$('.stop').on 'click', -> conference.stop()

$('.reset').on 'click', -> conference.reset()

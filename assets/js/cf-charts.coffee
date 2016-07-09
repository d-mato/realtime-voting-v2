window.app ||= {}
app.Views ||= {}
app.Models ||= {}

class app.Views.TimeChartView extends Backbone.View
  initialize: ->
    @chart = new Chart(document.getElementById("timeChart").getContext("2d"))
    if app.ManualMode
      @table = 'resetTable'
    else
      @table = 'timeTable'
    @listenTo @model, "change:#{@table}", @render

  render: ->
    timer = app.Timer
    # return false if @model.get('status') == 0
    tableArray = @model.get(@table)

    if app.ManualMode
      labels = tableArray.map -> ''
    else
      if tableArray.length > 20
        step = parseInt timeArray.length/20
      else
        step = 1

      labels = tableArray.map (val, index) =>
        if index%step == 0
          s = index*timer
          return parseInt(s/60)+':'+('0'+s%60).slice(-2)
        else
          return ''
    data =
      labels: labels
      datasets: [{
        fillColor: "rgba(220,220,220,0.2)",
        strokeColor: "rgba(220,220,220,1)",
        pointColor: "rgba(220,220,220,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(220,220,220,1)",
        data: tableArray
      }]
    options =
      bezierCurve: false
      scaleStartValue: 0
      scaleBeginAtZero: true
    @chart.Line(data, options)
    console.log "update time chart"

class app.Views.OfficeChartView extends Backbone.View
  initialize: ->
    @chart = new Chart(document.getElementById("officeChart").getContext("2d"))
    @listenTo @model, 'change:officeTable', @render
  render: ->
    # return false if @model.get('status') == 0
    obj = @model.get('officeTable')
    data =
      labels: Object.keys(obj)
      datasets: [{
        fillColor: "rgba(220,220,220,0.2)",
        strokeColor: "rgba(220,220,220,1)",
        pointColor: "rgba(220,220,220,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(220,220,220,1)",
        data: _.toArray(obj),
      }]
    @chart.Bar(data)
    console.log "update office chart"

class app.Views.PieChartView extends Backbone.View
  initialize: ->
    @chart = new Chart(document.getElementById('pieChart').getContext("2d"))
    @listenTo @model, 'change:_lastLikesPercentage', @render

  render: ->
    # return false if @model.get('status') == 0
    percentage = @model.get '_lastLikesPercentage'
    data = [
      {
        value: percentage
        color:"#F7464A"
        highlight: "#FF5A5E"
        label: "Red"
      }
      {
        value: 100-percentage
        color: "#46BFBD"
        highlight: "#5AD3D1"
        label: "Green"
      }
    ]
    @chart.Pie(data)
    console.log "update pie chart"

Chart.defaults.global.showTooltips = false
Chart.defaults.global.animation = false

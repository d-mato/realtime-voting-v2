DEBUG = false
DEBUG = true

$('.alert .close').on 'click', (e) ->
  $('.alert').hide()
  e.preventDefault()

reset = ->
  $('.like').prop('disabled', false)

update_alert = (msg) ->
  $('.alert span').text(msg)
  alert = $('.alert').show()
  setTimeout ->
    alert.slideUp(500)
  , 3000

io.socket.on 'reset', ->
  reset()
io.socket.on 'conference-started', ->
  update_alert 'Conference started!'
io.socket.on 'conference-stopped', ->
  update_alert 'Conference stopped!'

office = '赤坂'+parseInt(Math.random()*5+1)
key = location.href.split(/conferences\//)[1] # Conference key

$('.like').click ->
  $(@).prop('disabled', true)
  $.post '/likes', {office: office, key: key}, (res) ->
    console.log(res) if DEBUG

setInterval ->
  io.socket.post '/attendances', {office: office, key: key}, (res) ->
    # console.log(res) if DEBUG
, 3000

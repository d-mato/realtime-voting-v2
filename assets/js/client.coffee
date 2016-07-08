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

office = '赤坂02'
key = location.href.split(/conferences\//)[1] # Conference key

io.socket.on 'conference-stopped', (res) ->
  if res.key == key
    update_alert 'Conference stopped!'
    console.log(res)

io.socket.on 'conference-started', (res) ->
  if res.key == key
    update_alert 'Conference started!'
    console.log(res)

io.socket.on 'conference-opened', (res) ->
  console.log(res)

$('.like').click ->
  $(@).prop('disabled', true)
  $.post '/likes', {office: office, key: key}, (res) ->
    console.log(res) if DEBUG

setInterval ->
  $.post '/attendances', {office: office, key: key}, (res) ->
    console.log(res) if DEBUG
, 3000

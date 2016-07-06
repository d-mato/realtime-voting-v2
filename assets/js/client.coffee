office = '赤坂02'
key = location.href.split(/conferences\//)[1] # Conference key

io.socket.on 'conference-stopped', (res) ->
  if res.key == key
    console.log('Stopped')
    console.log(res)

io.socket.on 'conference-started', (res) ->
  if res.key == key
    console.log('Started')
    console.log(res)

io.socket.on 'conference-opened', (res) ->
  console.log(res)

$('.like').click ->
  $.post '/likes', {office: office, key: key}, (res) ->
    console.log(res)

setInterval ->
  $.post '/attendances', {office: office, key: key}, (res) ->
    console.log(res)
, 3000

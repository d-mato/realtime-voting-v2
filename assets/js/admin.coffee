$('.start').click ->
  $.ajax({
    url: location.href+'/start'
  }).done (conference) ->
    $('.status span').text(conference.status)

$('.stop').click ->
  $.ajax({
    url: location.href+'/stop'
  }).done (conference) ->
    $('.status span').text(conference.status)

io.socket.get '/like/11', {}, (res) ->
  console.log(res)

$('.reset').on 'click', ->
  $.ajax({url: location.href+'/reset'})

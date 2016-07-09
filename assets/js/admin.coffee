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

$('.reset').on 'click', ->
  $.ajax({url: location.href+'/reset'})

setInterval ->
  $.ajax({url: location.href+'/statistics'}).done (json) ->
    console.log json
, 3000

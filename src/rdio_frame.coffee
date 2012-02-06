$(document).ready ->
  window.WEB_SOCKET_SWF_LOCATION = "/public/vendor/socket.io/WebSocketMain.swf"
  socket = io.connect(undefined, {'force new connection': true})

  $console = $('#console')
  $console.empty()
  $console.log = (string) ->
    $console.append "#{string}\n"
    $("html,body").animate {scrollTop: $(document).height()}, 'fast'

  socket.on 'rdioframeactivate', (playback_token) ->
    $console.log "playback token: #{playback_token}"
    $('#rdio').rdio playback_token

  socket.on 'rdioframeplay', (key) ->
    $console.log "rdioframeplay: #{key}"
    $('#rdio').rdio().play key

  socket.emit 'rdioframeinitialize', window.location.toString()

  $('#rdio').bind 'ready.rdio', ->
    $console.log 'rdio is ready'
  $('#rdio').bind 'playStateChanged.rdio', (event, play_state) ->
    $console.log "play_state: #{play_state}"
  $('#rdio').bind 'playingTrackChanged.rdio', (event, playing_track, source_position) ->
    $console.log "duration #{playing_track.duration}" if playing_track
  $('#rdio').bind 'positionChanged.rdio', (event, position) ->
    $console.log "position: #{position}"
  # $('#rdio').bind 'playingSomewhereElse.rdio', (event, playing_somewhere_else) ->
  #   console.log 'playing_somewhere_else', playing_somewhere_else

socket = chrome.socket if chrome?

class WSS
  constructor: (@address = '0.0.0.0', @port = 9000) ->

  listen: ->
    socketResponder = (socketInfo) ->

    socket.create 'tcp', {}, socketResponder


exports.WSS = WSS

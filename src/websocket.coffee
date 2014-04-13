sockets = chrome.sockets if chrome?
bufferUtils = require './buffer-utils'
{Frame} = require './frame'

class WebSocket
  constructor: (@id) ->
    sockets.tcp.onReceive.addListener this.onReceive

  onReceive: (socketInfo) ->
    console.log 'onReceive'
    return if socketInfo.socketId != this.id
    e =
      'data': bufferUtils.fromBufferToString socketInfo.data
    this.onmessage e
    console.log 'onReceive ends'

  send: (data) ->
    onMessageSent = (writeInfo) ->
      console.log "Summary: " + JSON.stringify writeInfo

    frame = new Frame
    frame.setOperation Frame.DATA
    frame.setMessage data
    sockets.tcp.send this.id, frame.bundle(), onMessageSent

  # callbacks section
  onmessage: (event) ->

exports.WebSocket = WebSocket

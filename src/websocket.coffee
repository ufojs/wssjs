sockets = chrome.sockets if chrome?
bufferUtils = require './buffer-utils'

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
    onMessageSent = (resultCode) ->
      console.log 'Result Code: ' + resultCode

    buffer = bufferUtils.fromStringToBuffer data
    sockets.tcp.send this.id, buffer, onMessageSent

  # callbacks section
  onmessage: (event) ->

exports.WebSocket = WebSocket

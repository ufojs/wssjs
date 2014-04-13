sockets = chrome.sockets if chrome?
bufferUtils = require './buffer-utils'
{Frame} = require './frame'

class WebSocket
  @CONNECTING: 0
  @OPEN: 1
  @CLOSING: 2
  @CLOSED: 3
  
  constructor: (@id) ->
    self = this
    onReceive = (socketInfo) ->
      console.log 'socket onReceive callback'
      receivedFrame = new Frame socketInfo.data
      return if socketInfo.socketId != self.id
      
      if receivedFrame.op == Frame.CLOSE
        self.close() if self.readyState == WebSocket.OPEN
        sockets.tcp.disconnect self.id
        self.readyState = WebSocket.CLOSED
        return self.onclose()

      e =
        'data': receivedFrame.message
      self.onmessage e

    sockets.tcp.onReceive.addListener onReceive
    this.readyState = WebSocket.OPEN

  send: (data) ->
    onMessageSent = (writeInfo) ->
      console.log 'Summary: ' + JSON.stringify writeInfo

    frame = new Frame
    frame.setOperation Frame.DATA
    frame.setMessage data
    sockets.tcp.send this.id, frame.bundle(), onMessageSent

  close: () ->
    onMessageSent = (writeInfo) ->
      console.log 'Closing websocket'

    frame = new Frame
    frame.setOperation Frame.CLOSE
    this.readyState = WebSocket.CLOSING
    sockets.tcp.send this.id, frame.bundle(), onMessageSent
    

  # callbacks section
  onmessage: (event) ->
  onclose: () ->

exports.WebSocket = WebSocket

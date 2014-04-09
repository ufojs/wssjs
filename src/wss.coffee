{Message} = require './message'
{WebSocket} = require './websocket'
sockets = chrome.sockets if chrome?
Crypto = require 'crypto'

class WSS
  constructor: (@address = '0.0.0.0', @port = 9000) ->
    @id = -1
    @clientId = -1

  doHandshake: (request, clientId) ->
    console.log request

    # Magic websocket string used to create session key
    magicStr = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

    clientKey = request['Sec-WebSocket-Key'] + magicStr
    responseKey = Crypto.createHash 'sha1'
                        .update clientKey
                        .digest 'base64'

    response = new Message
    response.set 'Upgrade', 'websocket'
    response.set 'Connection', 'Upgrade'
    response.set 'Sec-WebSocket-Accept', responseKey

    console.log response

    onMessageSent = (status) ->
      console.log status

    sockets.tcp.send clientId, response.bundle(), onMessageSent
    this.onopen new WebSocket clientId

  listen: ->
    self = this

    onReceiveCallback = (socketInfo) ->
      console.log 'onReceive callback called'
      return if socketInfo.socketId != self.clientId
      r = new Message socketInfo.data
      self.doHandshake r, socketInfo.socketId if r['Upgrade']? and r['Upgrade'] == 'websocket'
      self.clientId = -1
            
    onAcceptCallback = (socketInfo) ->
      console.log 'onAccept callback called'
      return if socketInfo.socketId != self.id
      self.clientId = socketInfo.clientSocketId
      sockets.tcp.setPaused socketInfo.clientSocketId, false

    onListening = (resultCode) ->
      console.log 'onListening callback called'
      return self.onerror 'Error listening: code ' + resultCode if resultCode < 0
      sockets.tcpServer.onAccept.addListener onAcceptCallback
      sockets.tcp.onReceive.addListener onReceiveCallback

    onSocketCreated = (socketInfo) ->
      console.log 'onSocketCreated callback called'
      self.id = socketInfo.socketId
      sockets.tcpServer.listen self.id, self.address, self.port, onListening

    sockets.tcpServer.create {}, onSocketCreated

  # Callbacks section
  onerror: (error) ->
  onopen: (socket) ->

exports.WSS = WSS

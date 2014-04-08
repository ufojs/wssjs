{Message} = require('./message')
sockets = chrome.sockets if chrome?
Crypto = require 'crypto'

class WSS
  constructor: (@address = '0.0.0.0', @port = 9000) ->
    @id = -1

  doHandshake: (request, clientId) ->
    console.log(request)

    # Magic websocket string used to create session key
    magicStr = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

    clientKey = request['Sec-WebSocket-Key'] + magicStr
    console.log clientKey
    console.log Crypto
    responseKey = Crypto.createHash('sha1').update(clientKey).digest('base64')

    response = new Message
    response.set 'Upgrade', 'websocket'
    response.set 'Connection', 'Upgrade'
    response.set 'Sec-WebSocket-Accept', responseKey

    console.log response

    onMessageSent = (status) ->
      console.log status

    sockets.tcp.send clientId, response.bundle(), onMessageSent

  listen: ->
    self = this

    onReceiveCallback = (socketInfo) ->
      console.log 'onReceive callback called'
      #return if socketInfo.socketId != self.id
      r = new Message socketInfo.data
      self.doHandshake r, socketInfo.socketId if r['Upgrade']? and r['Upgrade'] == 'websocket'
            
    onAcceptCallback = (socketInfo) ->
      console.log 'onAccept callback called'
      console.log(socketInfo)
      return if socketInfo.socketId != self.id
      sockets.tcp.onReceive.addListener onReceiveCallback
      sockets.tcp.setPaused socketInfo.clientSocketId, false

    onListening = (resultCode) ->
      console.log 'onListening callback called'
      if resultCode < 0
        return self.onError('Error listening: code ' + resultCode)
      sockets.tcpServer.onAccept.addListener onAcceptCallback

    onSocketCreated = (socketInfo) ->
      console.log 'onSocketCreated callback called'
      self.id = socketInfo.socketId
      sockets.tcpServer.listen self.id, self.address, self.port, onListening

    sockets.tcpServer.create {}, onSocketCreated



  # Callbacks section
  onError: (error) ->

exports.WSS = WSS

{Request} = require('./request')
sockets = chrome.sockets if chrome?

class WSS
  constructor: (@address = '0.0.0.0', @port = 9000) ->
    @id = -1

  doHandshake: (request) ->
    console.log(request)

  listen: ->
    self = this

    onReceiveCallback = (socketInfo) ->
      console.log 'onReceive callback called'
      return if socketInfo.socketId != self.id
      r = new Request socketInfo.data
      self.doHandshake r if r['Upgrade']? and r['Upgrade'] == 'websocket'
            
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

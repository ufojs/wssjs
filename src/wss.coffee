{Message} = require('./message')
sockets = chrome.sockets if chrome?
btoa = require 'btoa' if not btoa?
{Sha1} = require('../lib/sha1')

class WSS
  constructor: (@address = '0.0.0.0', @port = 9000) ->
    @id = -1

  doHandshake: (request) ->
    console.log(request)

    toArray = (string) ->
      a = []
      a.push char for char in string
      return a

    toString = (array) ->
      s = ''
      s += String.fromCharCode char for char in array
      return s

    # Magic websocket string used to create session key
    magicStr = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

    clientKey = request['Sec-WebSocket-Key'] + magicStr
    sha1 = new Sha1
    sha1.reset()
    sha1.update toArray clientKey
    responseKey = btoa toString sha1.digest()




  listen: ->
    self = this

    onReceiveCallback = (socketInfo) ->
      console.log 'onReceive callback called'
      #return if socketInfo.socketId != self.id
      r = new Message socketInfo.data
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

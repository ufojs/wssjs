sockets = chrome.sockets if chrome?

class WSS
  constructor: (@address = '0.0.0.0', @port = 9000) ->
    @id = -1

  listen: ->
    self = this

    onConnection = (info) ->
      console.log 'onConnection callback called'

    onListening = (resultCode) ->
      console.log 'onListening callback called'
      if resultCode < 0
        return self.onError('Error listening: code ' + resultCode)
      sockets.tcpServer.onAccept.addListener(onConnection)

    onSocketCreated = (socketInfo) ->
      console.log 'onSocketCreated callback called'
      self.id = socketInfo.socketId
      sockets.tcpServer.listen self.id, self.address, self.port, onListening

    sockets.tcpServer.create {}, onSocketCreated

  # Callbacks section
  onError: (error) ->

exports.WSS = WSS

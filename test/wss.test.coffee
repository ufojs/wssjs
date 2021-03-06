﻿# Enabling BDD style
chai = require 'chai'
chai.should()
# Test lib
{Message} = require '../src/message'
# Mocking chrome socket api
{chrome} = require './chrome-mock.js'
rewire = require 'rewire'
# Getting UUT
{WSS} = require '../src/wss'
# Array buffer utilities
bufferUtils = require '../src/buffer-utils'

describe 'A websocket server', ->
  
  it 'should have a constructor', (done) ->
    currentServer = new WSS
    currentServer.should.not.be.null
    done()

  it 'should have a onerror callback', (done) ->
    currentServer = new WSS
    currentServer.should.respondTo 'onerror'
    done()

  it 'should have an invalid id', (done) ->
    currentServer = new WSS
    currentServer.id.should.be.equal -1
    done()

  it 'should have a bind address', (done) ->
    currentServer = new WSS '1.1.1.1'
    currentServer.address.should.be.equal '1.1.1.1'
    done()

  it 'should have port number', (done) ->
    currentServer = new WSS '2.2.2.2', 9999
    currentServer.port.should.be.equal 9999
    done()

  it 'should provide default values for port and address', (done) ->
    currentServer = new WSS
    currentServer.address.should.not.be.undefined
    currentServer.port.should.not.be.undefined
    currentServer.address.should.be.equal '0.0.0.0'
    currentServer.port.should.be.equal 9000
    done()

  it 'should provide listen method', (done) ->
    currentServer = new WSS
    currentServer.should.respondTo 'listen'
    done()

  it 'should create a tcp Chrome server socket', (done) ->
    wssModule = rewire '../src/wss'
    chrome.sockets.tcpServer.create = (opts, callback) -> 
      opts.should.be.an.instanceof Object
      callback.should.be.an.instanceof Function
      done()
    wssModule.__set__ 'sockets', chrome.sockets
    
    currentServer = new wssModule.WSS
    currentServer.listen()

  it 'should save current socket id', (done) ->
    wssModule = rewire '../src/wss'
    chrome.sockets.tcpServer.create = (opts, callback) -> 
      callback {'socketId': 'anID' }
    chrome.sockets.tcpServer.listen = (id, address, port, callback) ->
      currentServer.id.should.be.equal 'anID'
      done()
    wssModule.__set__ 'sockets', chrome.sockets

    currentServer = new wssModule.WSS
    currentServer.listen()

  it 'should put the socket in listen state', (done) ->
    wssModule = rewire '../src/wss'
    chrome.sockets.tcpServer.create = (opts, callback) -> 
      callback {'socketId': 'anID' }
    chrome.sockets.tcpServer.listen = (id, address, port, callback) ->
      id.should.be.equal 'anID'
      address.should.be.equal '0.0.0.0'
      port.should.be.equal 9000
      callback.should.be.an.instanceof Function
      done()
    wssModule.__set__ 'sockets', chrome.sockets

    currentServer = new wssModule.WSS
    currentServer.listen()

  it 'should invoke onerror callback when resultCode < 0', (done) ->
    wssModule = rewire '../src/wss'
    chrome.sockets.tcpServer.create = (opts, callback) -> 
      callback {'socketId': 'anID' }
    chrome.sockets.tcpServer.listen = (id, address, port, callback) ->
      callback -1
    wssModule.__set__ 'sockets', chrome.sockets

    currentServer = new wssModule.WSS
    currentServer.onerror = (error) ->
      error.should.be.equal 'Error listening: code -1'
      done()
    currentServer.listen()

  it 'should register an onAccept listener', (done) ->
    wssModule = rewire '../src/wss'
    chrome.sockets.tcpServer.create = (opts, callback) -> 
      callback {'socketId': 'anID' }
    chrome.sockets.tcpServer.listen = (id, address, port, callback) ->
      callback 0
    chrome.sockets.tcpServer.onAccept.addListener = (callback) ->
      callback.should.be.instanceof Function
      done()
    wssModule.__set__ 'sockets', chrome.sockets

    currentServer = new wssModule.WSS
    currentServer.listen()

  it 'should register an onReceive listener', (done) ->
    wssModule = rewire '../src/wss'
    chrome.sockets.tcpServer.create = (opts, callback) -> 
      callback {'socketId': 'anID' }
    chrome.sockets.tcpServer.listen = (id, address, port, callback) ->
      callback 0
    chrome.sockets.tcpServer.onAccept.addListener = (callback) ->
      callback {'socketId': 'anID' }
    chrome.sockets.tcp.onReceive.addListener = (callback) ->
      callback.should.be.instanceof Function
      done()
    wssModule.__set__ 'sockets', chrome.sockets

    currentServer = new wssModule.WSS
    currentServer.listen()

  it 'should un-pause the socket', (done) ->
    wssModule = rewire '../src/wss'
    chrome.sockets.tcpServer.create = (opts, callback) -> 
      callback {'socketId': 'anID' }
    chrome.sockets.tcpServer.listen = (id, address, port, callback) ->
      callback 0
    chrome.sockets.tcpServer.onAccept.addListener = (callback) ->
      callback {'socketId': 'anID', 'clientSocketId': 'otherId' }
    chrome.sockets.tcp.onReceive.addListener = (callback) ->
    chrome.sockets.tcp.setPaused = (id, status) ->
      id.should.be.equal 'otherId'
      status.should.be.equal false
      done()
    wssModule.__set__ 'sockets', chrome.sockets

    currentServer = new wssModule.WSS
    currentServer.listen()

  it 'should evaluate a websocket request', (done) ->
    packetArrayBuffer = bufferUtils.fromStringToBuffer 'Upgrade:websocket\n'
    wssModule = rewire '../src/wss'
    chrome.sockets.tcpServer.create = (opts, callback) -> 
      callback {'socketId': 'anID' }
    chrome.sockets.tcpServer.listen = (id, address, port, callback) ->
      callback 0
    chrome.sockets.tcpServer.onAccept.addListener = (callback) ->
      callback {'socketId': 'anID', 'clientSocketId': 'otherId' }
    chrome.sockets.tcp.onReceive.addListener = (callback) ->
      callback {'socketId': 'otherId', 'data': packetArrayBuffer}
    chrome.sockets.tcp.setPaused = (id, status) ->
    wssModule.__set__ 'sockets', chrome.sockets

    currentServer = new wssModule.WSS
    currentServer.doHandshake = (request) ->
      request.should.be.instanceof Message
      done()
    currentServer.listen()

  it 'should not evaluate any other requests', (done) ->
    packetArrayBuffer = bufferUtils.fromStringToBuffer 'GET / HTTP/1.1\n'
    wssModule = rewire '../src/wss'
    chrome.sockets.tcpServer.create = (opts, callback) -> 
      callback {'socketId': 'anID' }
    chrome.sockets.tcpServer.listen = (id, address, port, callback) ->
      callback 0
    chrome.sockets.tcpServer.onAccept.addListener = (callback) ->
      callback {'socketId': 'anID', 'clientSocketId': 'otherId' }
    chrome.sockets.tcp.onReceive.addListener = (callback) ->
      callback {'socketId': 'otherId', 'data': packetArrayBuffer}
    chrome.sockets.tcp.setPaused = (id, status) ->
    wssModule.__set__ 'sockets', chrome.sockets

    currentServer = new wssModule.WSS
    currentServer.doHandshake = (request) ->
      assert.fail()
    currentServer.listen()
    setTimeout done, 1000

  it 'should reply to a websocket request', (done) ->
    wssModule = rewire '../src/wss'
    chrome.sockets.tcp.send = (id, data) ->
      id.should.be.equal 'id'
      data = bufferUtils.fromBufferToString data
      data.should.be.equal 'HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: /AErEkZG6s+nFTmzfT4nQ6eMa2A=\r\n\r\n'
      done()

    class fakeWebsocket
      constructor: ->

    wssModule.__set__ 'sockets', chrome.sockets
    wssModule.__set__ 'WebSocket', fakeWebsocket

    currentServer = new wssModule.WSS
    currentServer.doHandshake({'Sec-WebSocket-Key': 'testkey'}, 'id')

  it 'should fire onopen callback when a new websocket is accept', (done) ->
    wssModule = rewire '../src/wss'
    chrome.sockets.tcp.send = (id, data) ->

    class fakeWebsocket
      constructor: (@id) ->

    wssModule.__set__ 'sockets', chrome.sockets
    wssModule.__set__ 'WebSocket', fakeWebsocket
    
    currentServer = new wssModule.WSS
    currentServer.should.respondTo 'onopen'
    currentServer.onopen = (socket) ->
      socket.id.should.be.equal 'id'
      done()
    currentServer.doHandshake({'Sec-WebSocket-Key': 'testkey'}, 'id')

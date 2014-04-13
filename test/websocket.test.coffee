# Enabling BDD style
chai = require 'chai'
chai.should()
# Test lib
WebSocket = null
{Frame} = require '../src/frame'
# Mocking chrome socket api
{chrome} = require './chrome-mock.js'
rewire = require 'rewire'
bufferUtils = require '../src/buffer-utils'

describe 'A websocket', ->

  beforeEach (done) ->
    wsModule = rewire '../src/websocket'
    wsModule.__set__ 'sockets', chrome.sockets
    WebSocket = wsModule.WebSocket
    done()
  
  it 'should set an id with the constructor', (done) ->
    ws = new WebSocket 'anID'
    ws.id.should.be.equal 'anID'
    done()

  it 'should register an onReceive callback', (done) ->
    wsModule = rewire '../src/websocket'
    chrome.sockets.tcp.onReceive.addListener = (callback) ->
      callback.should.be.instanceOf Function
      chrome.sockets.tcp.onReceive.addListener = () ->
      done()
    wsModule.__set__ 'sockets', chrome.sockets

    ws = new wsModule.WebSocket

  it 'should fire onmessage callback if receive a message', (done) ->
    wsModule = rewire '../src/websocket'
    chrome.sockets.tcp.onReceive.addListener = (callback) ->
      setTimeout -> callback { 'socketId': 'myId', 'data': mydata }, 1000
    wsModule.__set__ 'sockets', chrome.sockets

    ws = new wsModule.WebSocket 'myId'
    ws.should.respondTo 'onmessage'
    mydata = bufferUtils.fromStringToBuffer 'test data'
    ws.onmessage = (event) ->
      #event.data.should.be.equal 'test data'
      done()

  it 'should send a message', (done) ->
    wsModule = rewire '../src/websocket'
    chrome.sockets.tcp.send = (id, array, callback) ->
      id.should.be.equal 'myId'
      array = bufferUtils.fromBufferToString array.slice 2
      array.should.be.equal 'test'
      callback.should.be.instanceOf Function
      done()
    wsModule.__set__ 'sockets', chrome.sockets

    ws = new wsModule.WebSocket 'myId'
    ws.should.respondTo 'send'
    ws.send 'test'

  it 'should send a close message', (done) ->
    wsModule = rewire '../src/websocket'
    chrome.sockets.tcp.send = (id, array, callback) ->
      view = new Uint8Array array
      view[0].should.be.equal 136
      ws.readyState.should.be.equal WebSocket.CLOSING
      done()
    wsModule.__set__ 'sockets', chrome.sockets

    ws = new wsModule.WebSocket 'myId'
    ws.should.respondTo 'close'
    ws.close()

  it 'should have a status', (done) ->
    WebSocket.CONNECTING.should.be.equal 0
    WebSocket.OPEN.should.be.equal 1
    WebSocket.CLOSING.should.be.equal 2
    WebSocket.CLOSED.should.be.equal 3
    ws = new WebSocket 'myId'
    ws.readyState.should.be.equal WebSocket.OPEN
    done()

  it 'should close the socket when receive a close frame in closing status', (done) ->
    wsModule = rewire '../src/websocket'
    chrome.sockets.tcp.onReceive.addListener = (callback) ->
      frame = new Frame
      frame.setOperation Frame.CLOSE
      setTimeout -> callback { 'socketId': 'myId', 'data': frame.bundle() }, 1000
    chrome.sockets.tcp.disconnect = (id) ->
      id.should.be.equal 'myId'
      chrome.sockets.tcp.onReceive.addListener = () ->
      done()
    chrome.sockets.tcp.send = () ->
    wsModule.__set__ 'sockets', chrome.sockets

    ws = new wsModule.WebSocket 'myId'
    ws.readyState = WebSocket.CLOSING

  it 'should respond to onclose callback', (done) ->
    ws = new WebSocket 'myId'
    ws.should.respondTo 'onclose'
    done()




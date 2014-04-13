# Enabling BDD style
chai = require 'chai'
chai.should()
# Test lib
WebSocket = null
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
    ws = new WebSocket 'myId'
    ws.should.respondTo 'onmessage'
    mydata = bufferUtils.fromStringToBuffer 'test data'
    ws.onmessage = (event) ->
      event.data.should.be.equal 'test data'
      done()

    ws.onReceive { 'socketId': 'myId', 'data': mydata }

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

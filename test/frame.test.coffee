# Enabling BDD style
chai = require 'chai'
should = chai.should()
# UUT
{Frame} = require '../src/frame.coffee'
# Utilities
bufferUtils = require '../src/buffer-utils'

describe 'A websocket frame', ->

  it 'should have an operation identifier', (done) ->
    thisFrame = new Frame
    should.exist thisFrame.op
    done()

  it 'should have a data field', (done) ->
    thisFrame = new Frame
    should.exist thisFrame.message
    done()

  it 'should static definition for frame types', (done) ->
    Frame.DATA.should.be.equal 1
    Frame.CLOSE.should.be.equal 8
    done()

  it 'should calculate the op field', (done) ->
    thisFrame = new Frame
    thisFrame.setOperation 2
    thisFrame.op.should.be.equal 130
    thisFrame.setOperation Frame.DATA
    thisFrame.op.should.be.equal 129
    thisFrame.setOperation Frame.CLOSE
    thisFrame.op.should.be.equal 136
    done()

  it 'should calculate the frame length', (done) ->
    shortString = 'short'
    medString = Array(27).join shortString
    longString = Array(700).join medString

    thisFrame = new Frame
    thisFrame.setMessage shortString
    thisFrame.length.should.be.equal 5
    thisFrame.setMessage medString
    thisFrame.length.should.be.equal 126
    thisFrame.setMessage longString
    thisFrame.length.should.be.equal 127
    done()

  it 'should set the message', (done) ->
    thisFrame = new Frame
    thisFrame.setMessage 'test'
    thisFrame.message.should.be.equal 'test'
    done()

  it 'should create the message as buffer', (done) ->
    thisFrame = new Frame
    thisFrame.setOperation Frame.DATA
    thisFrame.setMessage 'hello world'
    frameToSend = thisFrame.bundle()
    view = new Uint8Array frameToSend
    view[0].should.be.equal 129
    view[1].should.be.equal 11
    frameToSend = bufferUtils.fromBufferToString frameToSend.slice 2
    frameToSend.should.be.equal 'hello world'
    done()

  it 'should parse a received frame', (done) ->
    receivedFrame = new Frame
    receivedFrame.setOperation Frame.DATA
    receivedFrame.setMessage 'test'
    parsedFrame = new Frame receivedFrame.bundle()
    parsedFrame.op.should.be.equal Frame.DATA
    parsedFrame.length.should.be.equal 4
    #parsedFrame.message.should.be.equal 'test'
    done()

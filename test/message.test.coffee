# Enabling BDD style
chai = require 'chai'
chai.should()
# Getting UUT
{Message} = require '../src/message'
# Array buffer utilities
bufferUtils = require '../src/buffer-utils'

describe 'An HTTP message', ->

  it 'should exists', (done) ->
    thisMessage = new Message
    thisMessage.should.not.be.undefined
    done()

  it 'should set headers as class field', (done) ->
    buffer = bufferUtils.fromStringToBuffer 'h1: test\nh2: test2\n\n'
    thisMessage = new Message buffer
    thisMessage.h1.should.be.equal 'test'
    thisMessage.h2.should.be.equal 'test2'
    done()

  it 'should be windows compatible', (done) ->
    buffer = bufferUtils.fromStringToBuffer 'h1: test\r\nh2: test2\r\n\r\n'
    thisMessage = new Message buffer
    thisMessage.h1.should.be.equal 'test'
    thisMessage.h2.should.be.equal 'test2'
    done()

  it 'should add a field to itself', (done) ->
    thisMessage = new Message
    thisMessage.set('testHeader', 'testBody')
    thisMessage['testHeader'].should.be.equal 'testBody'
    done()

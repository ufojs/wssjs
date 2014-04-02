# Enabling BDD style
chai = require 'chai'
chai.should()
# Getting UUT
{Request} = require '../src/request'

describe 'An HTTP request', ->

  getAsArrayBuffer = (string) ->
    buffer = new ArrayBuffer string.length
    view = new Uint8Array buffer
    view[current] = string.charCodeAt current for current in [0..string.length]
    return buffer

  it 'should exists', (done) ->
    thisRequest = new Request
    thisRequest.should.not.be.undefined
    done()

  it 'should convert an array buffer in string', (done) ->
    thisRequest = new Request
    buffer = getAsArrayBuffer 'test string'
    converted = thisRequest.asString buffer
    converted.should.be.equal 'test string'
    done()

  it 'should set headers as class field', (done) ->
    buffer = getAsArrayBuffer 'h1: test\nh2: test2\n\n'
    thisRequest = new Request buffer
    thisRequest.h1.should.be.equal 'test'
    thisRequest.h2.should.be.equal 'test2'
    done()

  it 'should be windows compatible', (done) ->
    buffer = getAsArrayBuffer 'h1: test\r\nh2: test2\r\n\r\n'
    thisRequest = new Request buffer
    thisRequest.h1.should.be.equal 'test'
    thisRequest.h2.should.be.equal 'test2'
    done()


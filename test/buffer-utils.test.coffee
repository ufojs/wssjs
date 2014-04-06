# Enabling BDD style
chai = require 'chai'
chai.should()
# Getting UUT
bufferUtils = require '../src/buffer-utils'

getAsArrayBuffer = (string) ->
    buffer = new ArrayBuffer string.length
    view = new Uint8Array buffer
    view[current] = string.charCodeAt current for current in [0..string.length]
    return buffer

describe 'Some utilities for array buffers', ->

  it 'should convert an array buffer in string', (done) ->
    buffer = getAsArrayBuffer 'test string'
    converted = bufferUtils.fromBufferToString buffer
    converted.should.be.equal 'test string'
    done()

  it 'should convert a string in array buffer', (done) ->
    buffer = getAsArrayBuffer 'test string'
    viewOriginal = new Uint8Array buffer
    converted = bufferUtils.fromStringToBuffer 'test string'
    view = new Uint8Array converted
    view[current].should.be.equal viewOriginal[current] for current in [0..10]
    done()

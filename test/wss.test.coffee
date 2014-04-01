# Enabling BDD style
chai = require 'chai'
chai.should()
# Getting UUT
{WSS} = require '../src/wss'

describe 'A websocket server', ->
  
  it 'should have a constructor', (done) ->
    currentServer = new WSS
    currentServer.should.not.be.equal null
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
    currentServer.address.should.not.be.equal undefined
    currentServer.port.should.not.be.equal undefined
    currentServer.address.should.be.equal '0.0.0.0'
    currentServer.port.should.be.equal 9000
    done()

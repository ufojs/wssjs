# Enabling BDD style
chai = require 'chai'
chai.should()
# Getting UUT
{WSS} = require '../src/wss'

describe 'A websocket server', ->
  it 'should have a constructor', ->
    currentServer = new WSS
    currentServer.should.not.equal null

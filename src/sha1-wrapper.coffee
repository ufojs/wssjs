btoa = require 'btoa' if not btoa?
{Sha1} = require('../lib/sha1')

toArray = (string) ->
  a = []
  a.push char for char in string
  return a

toString = (array) ->
  s = ''
  s += String.fromCharCode char for char in array
  return s

class Sha1Wrapper
  constructor: (@sha1 = new Sha1) ->

  reset: ->
    this.sha1.reset()

  update: (string) ->
    this.sha1.update toArray string

  digest: ->
    return btoa toString this.sha1.digest()

exports.Sha1 = Sha1Wrapper

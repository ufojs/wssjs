bufferUtils = require './buffer-utils'

class Frame

  @DATA: 1
  @CLOSE: 8

  constructor: (buffer) ->
    if not buffer?
      this.op = -1
      this.message = ''
      return
    view = new Uint8Array buffer
    data = []
    data.push element for element in view
    this.op = data[0] & 15
    this.length = data[1] & 127
    mask = data.slice 2, 6
    decoded = data.slice 6, 6 + this.length
    decoded = decoded.map (byte, index) ->
      return byte ^ mask[index % 4]
    this.message = bufferUtils.fromBufferToString decoded

  setOperation: (operation) ->
    this.op = 128 | (operation & 15)

  setMessage: (string) ->
    this.length = switch
      when string.length > 65535 then 127 
      when string.length > 125 then 126 
      else string.length

    this.message = string

  bundle: () ->
    bufferLength = this.message.length
    bufferLength += switch
      when this.length == 127 then 10
      when this.length == 126 then 4
      else 2
    buffer = new ArrayBuffer bufferLength
    view = new Uint8Array buffer

    view[0] = this.op
    view[1] = this.length

    lengthBytes = switch
      when this.length == 127 then 7
      when this.length == 126 then 1
      else 0
    stringLength = this.message.length
    for index in [lengthBytes..0]
      view[2 + index] = stringLength & 255
      stringLength = stringLength >> 8
    for index in [0..this.message.length]
      view[lengthBytes + index + 2] = this.message.charCodeAt index

    return buffer

exports.Frame = Frame


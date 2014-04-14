bufferUtils = require './buffer-utils'

class Frame

  @DATA: 129
  @CLOSE: 136

  constructor: (buffer) ->
    if not buffer?
      this.op = -1
      this.message = ''
      return
    view = new Uint8Array buffer
    data = []
    data.push element for element in view
    this.op = data[0]
    this.length = data[1] & 127
    mask = data.slice 2, 6
    decoded = data.slice 6, 6 + this.length
    decoded = decoded.map (byte, index) ->
      return byte ^ mask[index % 4]
    this.message = bufferUtils.fromBufferToString decoded

  setOperation: (operation) ->
    this.op = operation

  setMessage: (string) ->
    this.length = switch
      when string.length > 65535 then 127 
      when string.length > 125 then 126 
      else string.length

    this.message = string

  bundle: () ->
    headerLength = switch
      when this.length == 127 then 10
      when this.length == 126 then 4
      else 2
    header = new ArrayBuffer headerLength
    headerView = new Uint8Array header

    headerView[0] = this.op
    headerView[1] = this.length

    for index in [headerLength..3] by -1
      headerView[index] = (this.message.length >> (this.message.length-3-index) * 8) & 255

    body = bufferUtils.fromStringToBuffer this.message
    bodyView = new Uint8Array body

    frame = new Uint8Array headerView.length + bodyView.length
    frame.set headerView, 0
    frame.set bodyView, headerLength

    return frame.buffer

exports.Frame = Frame


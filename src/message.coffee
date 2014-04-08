bufferUtils = require './buffer-utils'

class Message
  constructor: (messageBuffer) ->
    return if not messageBuffer?
    headerArray = bufferUtils.fromBufferToString messageBuffer
    headerArray = headerArray.replace /\r\n/g, '\n'
    headerArray = headerArray.split '\n'
    for row in headerArray
      row = row.split ':'
      this[row[0]] = row[1].trim() if row.length == 2

  set: (header, content) ->
    this[header] = content

  bundle: () ->
    fields = Object.keys this
    functions = Object.keys this.__proto__

    isNotAFunction = (element) ->
      return functions.indexOf element == -1
    
    fields = fields.filter(isNotAFunction)
    
    pkt = 'HTTP/1.1 101 Switching Protocols\r\n'
    pkt += header + ': ' + this[header] + '\r\n' for header in fields
    pkt += '\r\n'

    console.log pkt

    return bufferUtils.fromStringToBuffer pkt

exports.Message = Message

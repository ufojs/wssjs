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


exports.Message = Message

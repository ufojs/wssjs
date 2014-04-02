class Request
  constructor: (messageBuffer) ->
    return if not messageBuffer?
    headerArray = this.asString messageBuffer
    headerArray = headerArray.replace /\r\n/g, '\n'
    headerArray = headerArray.split '\n'
    for row in headerArray
      row = row.split ':'
      this[row[0]] = row[1].trim() if row.length == 2

  asString: (buffer) ->
    array = new Uint8Array buffer
    string = ''
    string += String.fromCharCode current for current in array
    return string

exports.Request = Request

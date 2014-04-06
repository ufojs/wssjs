exports.fromBufferToString = (buffer) ->
  array = new Uint8Array buffer
  string = ''
  string += String.fromCharCode current for current in array
  return string

exports.fromStringToBuffer = (string) ->
  buffer = new ArrayBuffer string.length
  view = new Uint8Array buffer
  view[current] = string.charCodeAt current for current in [0..string.length]
  return buffer

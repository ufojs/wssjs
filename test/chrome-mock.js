var chrome = {
  'sockets': {
    'tcpServer': { 
      'create': function() {},
      'listen': function() {},
      'onAccept': {
        'addListener': function() {}
      },
      'setPaused': function() {}
    },
    'tcp': {
      'onReceive': {
        'addListener': function() {},
        'removeListener': function() {}
      },
      'setPaused': function() {},
      'send': function() {}
    }
  }
}

exports.chrome = chrome

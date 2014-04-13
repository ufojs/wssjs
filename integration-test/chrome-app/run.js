var wss = new ufo.WSS();
wss.onopen = function(socket) { 
  socket.send('teststring');
  socket.onmessage = function(e) {
    if(e.data == 'close')
      return socket.close();
    socket.send(e.data);
  };
};
wss.listen();

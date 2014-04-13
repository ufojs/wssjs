var wss = new ufo.WSS();
wss.onopen = function(socket) { 
  socket.send('teststring'); 
};
wss.listen();

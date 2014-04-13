describe('A test', function() {
  it('should open a ws connection', function(done) {
    var ws = new WebSocket('ws://127.0.0.1:9000');
    ws.onopen = function(event) { done() };
  });
  it('should send a message on a socket', function(done) {
    var ws = new WebSocket('ws://127.0.0.1:9000');
    var onmessage = function(event) { 
      event.data.should.be.equal('teststring'); 
      done()
    };
    ws.onopen = function(event) { 
      ws.onmessage = onmessage; 
    }
  });
});

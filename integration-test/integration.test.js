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
    };
  });
  it('should receive a message on a socket', function(done) {
    var ws = new WebSocket('ws://127.0.0.1:9000');
    ws.onopen = function(event) {
      ws.onmessage = function(event) {
        if(event.data != 'teststring') {
          event.data.should.be.equal('message');
          done();
        }
      };
      ws.send('message');
    };
  });
  it('should close a connection', function(done) {
    var ws = new WebSocket('ws://127.0.0.1:9000');
    ws.onopen = function(event) {
      ws.onclose = function() {
        done();
      };
      ws.send('close');
    };
  });
  it('should reply to a close', function(done) {
    var ws = new WebSocket('ws://127.0.0.1:9000');
    ws.onopen = function(event) {
      ws.onclose = function() {
        done();
      };
      ws.close();
    };
  });
});

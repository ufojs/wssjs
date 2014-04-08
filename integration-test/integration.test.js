describe('A test', function() {
  it('should open a ws connection', function(done) {
    var ws = new WebSocket('ws://127.0.0.1:9000');
    ws.onopen = function(event) { done() };
  });
});

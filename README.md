wssjs <img src="http://benschwarz.github.io/bower-badges/badge@2x.png" width="130" height="30">
=====

A websocket server for your browser (uses ChromeApp API)

[![GithubTag](http://img.shields.io/github/tag/ufojs/wssjs.svg)](https://github.com/ufojs/wssjs) [![Build Status](https://travis-ci.org/ufojs/wssjs.svg?branch=master)](https://travis-ci.org/ufojs/wssjs) [![Stories in Ready](https://badge.waffle.io/ufojs/wssjs.png?label=ready&title=Ready)](https://waffle.io/ufojs/wssjs) [![Gittip](http://img.shields.io/gittip/helloIAmPau.svg)](https://www.gittip.com/helloIAmPau/)

Install the dependencies and compile the stack using ``npm install`` in the root folder of this project.

You'll find the bundle in ``./lib/`` folder; import it in your chrome app project using the ``<script>`` HTML tag and enjoy your in-browser websocket server. A sample application is located into ``./integration-test`` folder.

### Ultra-rapid tutorial

```
var someSockets = {};
var socketServer = new ufo.WSS();
socketServer.onopen = function(socket) {
  socket.onmessage = function(event) {
    console.log(event.data);
  };
  socket.onclose = function() {
    delete someSockets[socket.id];
  };
  someSockets[socket.id] = socket;
};
socketServer.listen();
```

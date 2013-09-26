WebSocketClient = require('websocket').client;
net = require("net")
bindSockets = require "./bindSockets"

###
argv = require('optimist')
    .usage('Usage: $0 -x [num] -y [num]')
    .demand(['x','y'])
    .argv;
###

module.exports = class wst_client
  constructor: ()->
    @tcpServer = net.createServer();
    @wsClient = new WebSocketClient();

  # example:  start(8081, "wss://ws.domain.com:454", "dst.domain.com:22")
  # meaning: tunnel *:localport to remoteAddr by using websocket connection to wsHost
  # wsHostUrl:  ws:// denotes standard socket, wss:// denotes ssl socket
  start: (localPort, wsHostUrl, remoteAddr)->
    @tcpServer.listen(localPort)
    @tcpServer.on("connection", (tcpConn)=>
      console.log("Connection detected");
      @wsClient.on('connectFailed', (error)=>
        console.log('WS connect error: ' + error.toString());
        tcpConn.destroy();  # kill tunnel counter part
      );

      @wsClient.on('connect', (wsConn)->
        console.log('WebSocket connected, binding tunnel');
        bindSockets(wsConn, tcpConn);
      );
      #wsClient.connect('ws://localhost:8080/?dst=192.168.187.130:22', 'tunnel-protocol');
      @wsClient.connect("#{wsHostUrl}/?dst=#{remoteAddr}", 'tunnel-protocol');
    )
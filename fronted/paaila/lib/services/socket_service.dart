import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  bool _connected = false;

  factory SocketService() => _instance;

  SocketService._internal();

  void connect(String jwtToken) {
    if (_connected) return;

    socket = IO.io(
      'http://192.168.1.72:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': jwtToken})
          .setQuery({'token': jwtToken}) // Also send in query for compatibility
          .setExtraHeaders({
            'authorization': 'Bearer $jwtToken', // Restore header
          })
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      _connected = true;
      print('Socket connected');
    });

    socket.onDisconnect((_) {
      _connected = false;
      print('Socket disconnected');
    });

    socket.onConnectError((err) {
      print('Connection error: $err');
    });
  }

  void sendLocation(double lat, double lng) {
    if (!_connected) return;

    socket.emit("walk:start", {
      "latitude": lat,
      "longitude": lng,
    });
    print("Location sent: $lat, $lng");
  }

  void stopRun() {
    socket.emit("walk:stop");
  }

  void disconnect() {
    socket.disconnect();
    _connected = false;
  }
}

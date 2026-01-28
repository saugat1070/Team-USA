import 'package:socket_io_client/socket_io_client.dart' as IO;
import './data_socket_service.dart';
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
      
      // DataSocketService().sendTrailCoordinates("WRC College");
      // DataSocketService().sendTrailCoordinates("Pashupati Area");
      // DataSocketService().sendTrailCoordinates("Futsal Area");
      // DataSocketService().sendTrailCoordinates("Gharmikhola Trail");

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
    print("Connection status: $_connected");
    if (!_connected) return;

    socket.emit("walk:start", {"latitude": lat, "longitude": lng});
  }

  /// Sends each new position during an active run (continuous stream).
  /// Emit "walk:location" for the server to append to the current path.
  void sendLocationUpdate(double lat, double lng) {
    print("Location update sent: $lat, $lng");
    print("Connected: $_connected");

    if (!_connected) return;

    socket.emit("walk:start", {"latitude": lat, "longitude": lng});
  }

  void stopRun() {
    socket.emit("walk:stop");
  }

  void joinRoom(String roomId) {
    socket.emit("join-room", {"roomId": roomId});
  }

  void disconnect() {
    socket.disconnect();
    _connected = false;
  }
}

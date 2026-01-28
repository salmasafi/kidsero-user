import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final String _baseUrl = 'https://Bcknd.Kidsero.com';

  void connect(String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      _baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      log('[WS_LOG] Connected to WebSocket server: $_baseUrl');
    });

    _socket!.onAny((event, data) {
      log('[WS_LOG] Received event: $event | Data: $data');
    });

    _socket!.onDisconnect((reason) {
      log('[WS_LOG] Disconnected from WebSocket server. Reason: $reason');
    });

    _socket!.onConnectError((data) {
      log('[WS_LOG] Connection Error: $data');
    });

    _socket!.onError((data) {
      log('[WS_LOG] Socket Error: $data');
    });
  }

  void joinRide(String rideId) {
    if (_socket == null || !_socket!.connected) return;
    log('Joining ride: $rideId');
    _socket!.emit('joinRide', rideId);
  }

  void leaveRide(String rideId) {
    if (_socket == null || !_socket!.connected) return;
    log('Leaving ride: $rideId');
    _socket!.emit('leaveRide', rideId);
  }

  void onLocationUpdate(Function(dynamic) callback) {
    if (_socket == null) return;
    _socket!.on('locationUpdate', (data) {
      log('Location updated received: $data');
      callback(data);
    });
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}

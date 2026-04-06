import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? socket;
  final _orderController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get orderStream => _orderController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  void connect(String? token) {
    if (socket != null && socket!.connected) return;

    // Remove '/api' from the base URL for socket connection
    final socketUrl = apiBase.replaceFirst('/api', '');

    socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders(
            token != null ? {'Authorization': 'Bearer $token'} : {},
          )
          .build(),
    );

    socket!.onConnect((_) {
      debugPrint('✅ Connected to Socket Server');
    });

    socket!.on('new_order', (data) {
      debugPrint('📦 New Order received: $data');
      _orderController.add(Map<String, dynamic>.from(data));
    });

    socket!.on('order_status_update', (data) {
      debugPrint('🔔 Order Status Update: $data');
      _statusController.add(Map<String, dynamic>.from(data));
    });

    socket!.onConnectError((err) => debugPrint('❌ Socket Connect Error: $err'));
    socket!.onDisconnect((_) => debugPrint('🔌 Socket Disconnected'));
  }

  void joinRestaurantRoom(String restaurantId) {
    socket?.emit('join', restaurantId);
    debugPrint('🚪 Joined Restaurant Room: $restaurantId');
  }

  void joinCustomerRoom(String customerId) {
    socket?.emit('join', customerId);
    debugPrint('🚪 Joined Customer Room: $customerId');
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
  }

  void dispose() {
    _orderController.close();
    _statusController.close();
    disconnect();
  }
}

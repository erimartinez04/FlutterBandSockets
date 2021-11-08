import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  ServerStatus get serverStatus => _serverStatus;

  late IO.Socket _socket;
  IO.Socket get socket => _socket;

  SocketService() {
    initConfig();
  }

  initConfig() {
    _socket = IO.io('http://10.0.2.2:3000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.on('connect_error', (err) => {print(err)});
    _socket.on('connect', (_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
      print('connect');
    });

    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
      print('disconnect');
    });

    _socket.on('new-message', (payload) {
      notifyListeners();
      print(payload);
    });
  }
}

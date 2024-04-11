import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:myrgb/network/udp_connect.dart';

class ServerService {
  final UDPController udpController = Get.put(UDPController());
  Socket? _socket;

  late String serverip;
  late int serverport;
  var user_close = false;

  Future<void> connectToServer() async {
    print("object");
    try {
      user_close = false;
      serverip = udpController.ipAddress.value;
      print(serverip);
      final socket = await Socket.connect(serverip, 8080);
      _socket = socket;
      print(
          'Connected to ${_socket?.remoteAddress.address}:${_socket?.remotePort}');
      debugPrint('starting');
      user_close = true;
      socket.done.then((_) {
        debugPrint('Connection to the server is closed.');
        if (user_close == false) reconnect();
      }).catchError((error) {
        if (error is SocketException) {
          print('SocketException: ${error.message}');

          reconnect();
        } else {
          print('Error in socket: $error');
        }
      });
    } catch (e) {
      print('Failed to connect to the server: $e');
      reconnect();
    }
  }

  void handleConnectionStatus(Datagram datagram) {
    final connectionStatus = datagram.data[0] == 1;
    print(
        'Connection status: ${connectionStatus ? 'Connected' : 'Disconnected'}');
  }

  void close() {
    user_close = true;
    _socket?.close();
  }

  void reconnect() {
    Timer(const Duration(seconds: 2), () {
      connectToServer();
    });
  }

  void sendMessage(List<int> message) {
    if (_socket != null) {
      _socket!.add(message);
    }
  }
}

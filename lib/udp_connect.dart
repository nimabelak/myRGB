import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:myrgb/main.dart';
import 'package:myrgb/server.dart';


class UDPController extends GetxController {
  final _connected = 0.obs;
  final ipAddress = "192.168.1.255".obs;
  RawDatagramSocket? _udpSocket;
  RawDatagramSocket? _udpGetSettingSocket;
  RawDatagramSocket? _udpAddAutoSocket;

  int get connected => _connected.value;
  String get ip => ipAddress.value;

  @override
  void onInit() {
    discoverDevice();
    super.onInit();
  }

  @override
  void onClose() {
    closeSockets();
    super.onClose();
  }

  Future<void> discoverDevice() async {
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _udpSocket?.broadcastEnabled = true;
    List<int> data = [255, 2, 255];
    print(data);
    receiveData();
    _udpSocket?.send(data, InternetAddress(ipAddress.value), 8080);
  }

void receiveData() async {
    Get.put(ServerService());
    
  const int port = 8081;
  _udpAddAutoSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
  _udpAddAutoSocket?.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      Datagram? datagram = _udpAddAutoSocket?.receive();
      if (datagram != null) {
        locator<ServerService>().handleConnectionStatus(datagram);
      }
    }
  });
}

  void closeSockets() {
    _udpSocket?.close();
    _udpGetSettingSocket?.close();
    _udpAddAutoSocket?.close();
  }
}
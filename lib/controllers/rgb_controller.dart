import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myrgb/network/udp_connect.dart';

class RGBColorPickerController extends GetxController {
  final UDPController udpController = Get.put(UDPController());
  final selectedColor = Colors.white.obs;
  final _currentIndex = 0.obs;
  var pageIndex = 1.obs;
  Timer? _debounce;

  Color get selectedColorGetter => selectedColor.value;
  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    udpController.discoverDevice();
    super.onInit();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void changeIndex(int index) {
    _currentIndex.value = index;
  }
}

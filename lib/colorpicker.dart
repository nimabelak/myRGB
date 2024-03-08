import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:myrgb/main.dart';
import 'package:myrgb/server.dart';
import 'package:myrgb/udp_connect.dart';

class RGBColorPickerController extends GetxController {
  final UDPController udpController = Get.put(UDPController());
  final _selectedColor = Colors.white.obs;
  final _currentIndex = 0.obs;
  Timer? _debounce;

  Color get selectedColor => _selectedColor.value;
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

  void changeColor(Color color) {
    _selectedColor.value = color;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), () {
      debugPrint("RED IS : ${color.red}");
      debugPrint("GREEN IS : ${color.green}");
      debugPrint("BLUE IS : ${color.blue}");
    });
  }

  void changeIndex(int index) {
    _currentIndex.value = index;
  }
}

class RGBColorPickerScreen extends StatelessWidget {
  final controller = Get.put(RGBColorPickerController());
  final udpcontroller = Get.put(UDPController());
  final serverService = Get.put(ServerService());

  @override
  Widget build(BuildContext context) {
    //serverService.connectToServer();

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('RGB'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.power_settings_new),
              onPressed: () {
                // Handle power button press
              },
            ),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 20, 43, 66),
      ),
      backgroundColor: const Color.fromARGB(255, 20, 43, 66),
      body: IndexedStack(
        index: controller.currentIndex,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.wifi,
                      size: 32,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                  ],
                ),
                Obx(
                  () => ColorPicker(
                    displayThumbColor: true,
                    enableAlpha: false,
                    colorPickerWidth: 380.0,
                    pickerAreaHeightPercent: 0.7,
                    paletteType: PaletteType.hueWheel,
                    pickerColor: controller.selectedColor,
                    onColorChanged: controller.changeColor,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        udpcontroller.discoverDevice();

                        controller._selectedColor.value =
                            const Color.fromARGB(255, 255, 0, 0);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 0, 0),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        controller._selectedColor.value =
                            const Color.fromARGB(255, 0, 255, 0);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 255, 0),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        controller._selectedColor.value =
                            const Color.fromARGB(255, 0, 0, 255);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 255),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        controller._selectedColor.value =
                            const Color.fromARGB(255, 255, 255, 0);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 0),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        controller._selectedColor.value =
                            const Color.fromARGB(255, 255, 0, 255);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 0, 255),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        controller._selectedColor.value =
                            const Color.fromARGB(255, 0, 255, 255);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 255, 255),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Center(
            child: Text('Second Screen'),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex,
          onTap: controller.changeIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.color_lens),
              label: 'Color Picker',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mode),
              label: 'Second Screen',
            ),
          ],
        ),
      ),
    );
  }
}

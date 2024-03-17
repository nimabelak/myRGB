import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
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

  void changeIndex(int index) {
    _currentIndex.value = index;
  }
}

class RGBColorPickerScreen extends StatelessWidget {
  final controller = Get.put(RGBColorPickerController());
  final udpcontroller = Get.put(UDPController());
  final serverService = Get.put(ServerService());

  void setParams(int red, int green, int blue, int brightness, int mode) {
    udpcontroller.red.value = red;
    udpcontroller.green.value = green;
    udpcontroller.blue.value = blue;
    udpcontroller.brightness.value = brightness;
    udpcontroller.mode.value = mode;
    udpcontroller.discoverDevice();
  }

  void changeColor(Color color) {
    controller._selectedColor.value = color;
    setParams(
      controller._selectedColor.value.red,
      controller._selectedColor.value.green,
      controller._selectedColor.value.blue,
      udpcontroller.brightness.value,
      udpcontroller.mode.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    //serverService.connectToServer();
    final List<String> dropdownValues = [
      'Static',
      'Rainbow',
      'ColorWipe',
      'TheaterChase',
      'Breathing',
      'Comet',
      'TheaterChase2',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('RGB'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(
              () => IconButton(
                icon: Icon(
                  Icons.power_settings_new,
                  color: udpcontroller.turnOff.value ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  udpcontroller.turnOff.value = !udpcontroller.turnOff.value;
                  if (udpcontroller.turnOff.value) {
                    // Turning off
                    print(udpcontroller.prevBrightness.value);
                    print(udpcontroller.brightness.value);
                    udpcontroller.prevBrightness.value =
                        udpcontroller.brightness.value;
                    udpcontroller.brightness.value = 0;

                    udpcontroller.discoverDevice();
                  } else {
                    // Turning on
                    udpcontroller.brightness.value =
                        udpcontroller.prevBrightness.value;
                    print(udpcontroller.brightness.value);
                    print(udpcontroller.prevBrightness.value);
                    udpcontroller.discoverDevice();
                  }
                },
              ),
            ),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 20, 43, 66),
      ),
      backgroundColor: const Color.fromARGB(255, 20, 43, 66),
      body: Obx(
        () => SingleChildScrollView(
          child: IndexedStack(
            index: controller.currentIndex,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Obx(
                      () => ColorPicker(
                        displayThumbColor: true,
                        enableAlpha: false,
                        colorPickerWidth: 380.0,
                        pickerAreaHeightPercent: 0.7,
                        paletteType: PaletteType.hueWheel,
                        pickerColor: controller.selectedColor,
                        onColorChanged: changeColor,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            setParams(255, 0, 0, udpcontroller.brightness.value,
                                udpcontroller.mode.value);

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
                        const SizedBox(width: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            setParams(0, 255, 0, udpcontroller.brightness.value,
                                udpcontroller.mode.value);
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
                        const SizedBox(width: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            setParams(0, 0, 255, udpcontroller.brightness.value,
                                udpcontroller.mode.value);
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
                        const SizedBox(width: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            setParams(
                                255,
                                255,
                                0,
                                udpcontroller.brightness.value,
                                udpcontroller.mode.value);
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
                        const SizedBox(width: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            setParams(
                                255,
                                0,
                                255,
                                udpcontroller.brightness.value,
                                udpcontroller.mode.value);
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
                        const SizedBox(width: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            setParams(
                                0,
                                255,
                                255,
                                udpcontroller.brightness.value,
                                udpcontroller.mode.value);
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
                        const SizedBox(width: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            setParams(
                                255,
                                70,
                                10,
                                udpcontroller.brightness.value,
                                udpcontroller.mode.value);
                            controller._selectedColor.value =
                                const Color.fromARGB(255, 255, 70, 10);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 70, 10),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Text(
                      "Brightness",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Slider(
                      activeColor: Colors.cyan[300],
                      inactiveColor: Colors.cyan[100],
                      value: udpcontroller.brightness.value.toDouble(),
                      onChanged: (value) {
                        udpcontroller.brightness.value = value.toInt();
                        setParams(
                            controller._selectedColor.value.red,
                            controller._selectedColor.value.green,
                            controller._selectedColor.value.blue,
                            udpcontroller.brightness.value,
                            udpcontroller.mode.value);
                      },
                      onChangeEnd: (newValue) {
                        udpcontroller.brightness.value = newValue.toInt();
                      },
                      min: 0,
                      max: 255,
                      divisions: 128,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Text(
                      "Mode",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    DropdownButton<String>(
                      value: udpcontroller.dropdownValue.value,
                      style: TextStyle(
                        color: Colors.cyan[100],
                      ),
                      onChanged: (String? newValue) {
                        udpcontroller.dropdownValue.value = newValue!;

                        int selectedIndex = dropdownValues.indexOf(newValue);
                        udpcontroller.mode.value = selectedIndex;
                        setParams(
                            controller._selectedColor.value.red,
                            controller._selectedColor.value.green,
                            controller._selectedColor.value.blue,
                            udpcontroller.brightness.value,
                            udpcontroller.mode.value);

                        //print('Selected index: $selectedIndex');
                      },
                      items: dropdownValues
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: 42,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

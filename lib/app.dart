import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myrgb/colorpicker.dart';
import 'package:myrgb/music.dart';

class RGBController extends GetxController {
  var currentIndex = 0.obs;
}

class App extends StatelessWidget {
  final RGBController controller = Get.put(RGBController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [RGBColorPickerScreen(), Music()],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          selectedItemColor: Colors.deepOrange,
        currentIndex: controller.currentIndex.value,
          onTap: (int index) {
            controller.currentIndex.value = index;
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.color_lens),
              label: 'Color Picker',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Music',
            ),
          ],
        ),
      ),
    );
  }
}

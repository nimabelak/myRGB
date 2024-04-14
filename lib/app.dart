import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:myrgb/Pages/colorpicker.dart';
import 'package:myrgb/Pages/music.dart';
import 'package:myrgb/controllers/rgb_controller.dart';
import 'package:navigation_view/item_navigation_view.dart';
import 'package:navigation_view/navigation_view.dart';

class App extends StatelessWidget {
  final RGBColorPickerController _rgbColorPickerController =
      Get.put(RGBColorPickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Stack(children: [
          _rgbColorPickerController.pageIndex.value == 1
              ? RGBColorPickerScreen()
              : Music(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavigationView(
              onChangePage: (c) {
                _rgbColorPickerController.pageIndex.value == 1
                    ? _rgbColorPickerController.pageIndex.value = 0
                    : _rgbColorPickerController.pageIndex.value = 1;
              },
              backgroundColor: Color.fromARGB(255, 13, 26, 39),
              borderRadius: BorderRadius.circular(6),
              color: Colors.cyan[300],
              curve: Curves.ease,
              durationAnimation: const Duration(milliseconds: 400),
              items: [
                ItemNavigationView(
                    childAfter: Icon(
                      Icons.music_note,
                      color: Colors.cyan[100],
                      size: 30,
                    ),
                    childBefore: Icon(
                      Icons.music_note_outlined,
                      color: Colors.grey.withAlpha(60),
                      size: 30,
                    )),
                ItemNavigationView(
                    childAfter: Icon(
                      Icons.color_lens,
                      color: Colors.cyan[100],
                      size: 30,
                    ),
                    childBefore: Icon(
                      Icons.color_lens_outlined,
                      color: Colors.grey.withAlpha(60),
                      size: 30,
                    )),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

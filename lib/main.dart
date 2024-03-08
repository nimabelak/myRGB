import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myrgb/colorpicker.dart';

void main() {
  runApp(const MyApp());
}

final locator = GetInstance();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My RGB',
      theme: ThemeData.dark(),
      home: RGBColorPickerScreen(),
    );
  }
}




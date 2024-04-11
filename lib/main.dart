import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myrgb/app.dart';
import 'package:myrgb/Pages/colorpicker.dart';

void main() {
  runApp(const MyApp());
}

final locator = GetInstance();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My RGB',
      theme: ThemeData.dark(),
      home: App(),
    );
  }
}

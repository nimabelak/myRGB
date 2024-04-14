import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:async';

class RecordController extends GetxController {
  final MethodChannel _methodChannel = const MethodChannel('getDecibel');
  double _maxPeak = Platform.isIOS ? 1 : 32786.0;
  double _currentMin = 0;
  var isRecording = false.obs;

  var lastValue = 0.0.obs;
  var alpha = 0.09.obs;
  var offset = 0.0.obs;
  var minThreshold = 0.03.obs;

  double smoothValue(double value) {
    lastValue.value = value * alpha.value + lastValue * (1 - alpha.value);
    return lastValue.value;
  }

  Future<double?> getDecibel() async {
    var db = await _methodChannel.invokeMethod('getDecibel');
    return db;
  }

  double mapNumber(
      double value, double inMin, double inMax, double outMin, double outMax) {
    double finalVal =
        outMin + (outMax - outMin) * ((value - inMin) / (inMax - inMin));
    if (finalVal > 255) finalVal = 255;
    return finalVal;
  }

  Future<double?> getDBvalue() async =>
      await AudioWaveformsInterface.instance.getDecibel();

  double normalise(double peak) {
    final absDb = peak.abs();
    _maxPeak = max(absDb, _maxPeak);
    final scaledWave = (absDb - _currentMin) / (_maxPeak - _currentMin);
    return scaledWave;
  }
}
